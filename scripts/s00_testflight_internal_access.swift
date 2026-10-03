// Mirror the existing Lecture Asset internal TestFlight testers onto Everwhile.
// Uses only opaque tester IDs in logs; never prints emails, JWTs, or raw API responses.
import CryptoKit
import Foundation

struct ASCError: Error {
    let message: String
}

func base64URL(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func makeToken(key: P256.Signing.PrivateKey, keyID: String, issuerID: String) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let header: [String: Any] = ["alg": "ES256", "kid": keyID, "typ": "JWT"]
    let claims: [String: Any] = [
        "iss": issuerID,
        "iat": now,
        "exp": now + 600,
        "aud": "appstoreconnect-v1",
    ]
    let body = base64URL(try JSONSerialization.data(withJSONObject: header)) + "." +
        base64URL(try JSONSerialization.data(withJSONObject: claims))
    let signature = try key.signature(for: Data(body.utf8))
    return body + "." + base64URL(signature.rawRepresentation)
}

struct API {
    let key: P256.Signing.PrivateKey
    let keyID: String
    let issuerID: String

    func request(_ method: String, _ path: String, query: [URLQueryItem] = [], body: [String: Any]? = nil, expected: Set<Int>) throws -> (Int, [String: Any]?) {
        var components = URLComponents(string: "https://api.appstoreconnect.apple.com/v1/" + path)!
        if !query.isEmpty { components.queryItems = query }
        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        req.setValue("Bearer " + (try makeToken(key: key, keyID: keyID, issuerID: issuerID)), forHTTPHeaderField: "Authorization")
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let sem = DispatchSemaphore(value: 0)
        var dataOut: Data?
        var responseOut: URLResponse?
        var errorOut: Error?
        URLSession.shared.dataTask(with: req) { data, response, error in
            dataOut = data
            responseOut = response
            errorOut = error
            sem.signal()
        }.resume()

        guard sem.wait(timeout: .now() + 30) == .success,
              errorOut == nil,
              let http = responseOut as? HTTPURLResponse else {
            throw ASCError(message: "network")
        }
        guard expected.contains(http.statusCode) else {
            var safe = "http_\(http.statusCode)_\(path)"
            if let data = dataOut,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errors = json["errors"] as? [[String: Any]],
               let first = errors.first {
                let code = (first["code"] as? String ?? "unknown").replacingOccurrences(of: " ", with: "_")
                let title = (first["title"] as? String ?? "unknown").replacingOccurrences(of: " ", with: "_")
                safe += "_code_\(code)_title_\(title)"
            }
            throw ASCError(message: safe)
        }
        guard let data = dataOut, !data.isEmpty else { return (http.statusCode, nil) }
        let json = try JSONSerialization.jsonObject(with: data)
        return (http.statusCode, json as? [String: Any])
    }

    func getItems(_ path: String, query: [URLQueryItem] = []) throws -> [[String: Any]] {
        let (_, json) = try request("GET", path, query: query, expected: [200])
        guard let items = json?["data"] as? [[String: Any]] else {
            throw ASCError(message: "bad_json_\(path)")
        }
        return items
    }

    func getItem(_ path: String, query: [URLQueryItem] = []) throws -> [String: Any] {
        let (_, json) = try request("GET", path, query: query, expected: [200])
        guard let item = json?["data"] as? [String: Any] else {
            throw ASCError(message: "bad_json_\(path)")
        }
        return item
    }
}

func id(_ item: [String: Any]) throws -> String {
    guard let value = item["id"] as? String else { throw ASCError(message: "missing_id") }
    return value
}

func appID(_ api: API, bundleID: String) throws -> String {
    let items = try api.getItems("apps", query: [
        URLQueryItem(name: "filter[bundleId]", value: bundleID),
        URLQueryItem(name: "limit", value: "2"),
    ])
    guard items.count == 1 else { throw ASCError(message: "app_lookup_\(bundleID)") }
    return try id(items[0])
}

func groups(_ api: API, appID: String) throws -> [[String: Any]] {
    try api.getItems("apps/\(appID)/betaGroups", query: [
        URLQueryItem(name: "fields[betaGroups]", value: "name,isInternalGroup,hasAccessToAllBuilds"),
        URLQueryItem(name: "limit", value: "200"),
    ])
}

func internalGroups(_ items: [[String: Any]]) -> [[String: Any]] {
    items.filter {
        guard let attrs = $0["attributes"] as? [String: Any] else { return false }
        return attrs["isInternalGroup"] as? Bool == true
    }
}

func testerIDs(_ api: API, groupID: String) throws -> Set<String> {
    Set(try api.getItems("betaGroups/\(groupID)/relationships/betaTesters", query: [
        URLQueryItem(name: "limit", value: "200"),
    ]).compactMap { $0["id"] as? String })
}

func buildID(_ api: API, appID: String, buildNumber: String) throws -> String {
    let items = try api.getItems("builds", query: [
        URLQueryItem(name: "filter[app]", value: appID),
        URLQueryItem(name: "filter[version]", value: buildNumber),
        URLQueryItem(name: "fields[builds]", value: "version,processingState,buildAudienceType"),
        URLQueryItem(name: "limit", value: "2"),
    ])
    guard items.count == 1,
          let attrs = items[0]["attributes"] as? [String: Any],
          attrs["processingState"] as? String == "VALID" else {
        throw ASCError(message: "build_not_valid_\(buildNumber)")
    }
    return try id(items[0])
}

func betaGroupIDsForBuild(_ api: API, buildID: String) throws -> Set<String> {
    Set(try api.getItems("builds/\(buildID)/relationships/betaGroups", query: [
        URLQueryItem(name: "limit", value: "200"),
    ]).compactMap { $0["id"] as? String })
}

func ensureInternalTesterCanSeeApp(_ api: API, testerID: String, appID: String) throws {
    let tester = try api.getItem("betaTesters/\(testerID)", query: [
        URLQueryItem(name: "fields[betaTesters]", value: "email"),
    ])
    guard let testerAttrs = tester["attributes"] as? [String: Any],
          let email = testerAttrs["email"] as? String,
          !email.isEmpty else {
        throw ASCError(message: "internal_tester_email_unavailable")
    }

    let users = try api.getItems("users", query: [
        URLQueryItem(name: "filter[username]", value: email),
        URLQueryItem(name: "fields[users]", value: "username,roles,allAppsVisible"),
        URLQueryItem(name: "limit", value: "2"),
    ])
    guard users.count == 1 else {
        throw ASCError(message: "internal_tester_appstore_user_missing")
    }
    let user = users[0]
    let userID = try id(user)
    let attrs = user["attributes"] as? [String: Any] ?? [:]
    if attrs["allAppsVisible"] as? Bool == true {
        return
    }

    let visible = Set(try api.getItems("users/\(userID)/relationships/visibleApps", query: [
        URLQueryItem(name: "limit", value: "200"),
    ]).compactMap { $0["id"] as? String })
    if visible.contains(appID) {
        return
    }

    let body: [String: Any] = [
        "data": [["type": "apps", "id": appID]]
    ]
    _ = try api.request("POST", "users/\(userID)/relationships/visibleApps", body: body, expected: [204])
    print("S00_TF_INTERNAL_USER_APP_ACCESS_ADDED")
}

let args = CommandLine.arguments
guard args.count == 3,
      let keyID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_KEY_ID"],
      let issuerID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_ISSUER_ID"] else {
    print("S00_TF_INTERNAL_ACCESS_FAILED configuration")
    exit(1)
}

do {
    let key = try P256.Signing.PrivateKey(
        pemRepresentation: String(contentsOfFile: args[1], encoding: .utf8)
    )
    let api = API(key: key, keyID: keyID, issuerID: issuerID)
    let buildNumber = args[2]

    let lectureApp = try appID(api, bundleID: "com.zhangsfish.lectureasset")
    let everwhileApp = try appID(api, bundleID: "com.zhangsfish.elapse")

    let lectureInternal = internalGroups(try groups(api, appID: lectureApp))
    guard !lectureInternal.isEmpty else {
        throw ASCError(message: "lecture_internal_group_missing")
    }

    var sourceTesterIDs = Set<String>()
    for group in lectureInternal {
        sourceTesterIDs.formUnion(try testerIDs(api, groupID: try id(group)))
    }
    guard !sourceTesterIDs.isEmpty else {
        throw ASCError(message: "lecture_internal_testers_missing")
    }
    print("S00_TF_SOURCE_INTERNAL_TESTERS count=\(sourceTesterIDs.count)")

    var everInternal = internalGroups(try groups(api, appID: everwhileApp))
    let targetGroupID: String

    if let group = everInternal.first {
        targetGroupID = try id(group)
        let attrs = group["attributes"] as? [String: Any] ?? [:]
        if attrs["hasAccessToAllBuilds"] as? Bool != true {
            let body: [String: Any] = [
                "data": [
                    "type": "betaGroups",
                    "id": targetGroupID,
                    "attributes": ["hasAccessToAllBuilds": true],
                ]
            ]
            _ = try api.request("PATCH", "betaGroups/\(targetGroupID)", body: body, expected: [200])
            print("S00_TF_INTERNAL_GROUP_AUTO_DISTRIBUTION_ENABLED")
        }
    } else {
        let body: [String: Any] = [
            "data": [
                "type": "betaGroups",
                "attributes": [
                    "name": "Everwhile Internal",
                    "isInternalGroup": true,
                    "hasAccessToAllBuilds": true,
                    "feedbackEnabled": true,
                ],
                "relationships": [
                    "app": [
                        "data": ["type": "apps", "id": everwhileApp]
                    ]
                ],
            ]
        ]
        let (_, json) = try api.request("POST", "betaGroups", body: body, expected: [201])
        guard let data = json?["data"] as? [String: Any] else {
            throw ASCError(message: "group_create_bad_json")
        }
        targetGroupID = try id(data)
        print("S00_TF_INTERNAL_GROUP_CREATED")
        everInternal = [data]
    }

    let existing = try testerIDs(api, groupID: targetGroupID)
    let missing = sourceTesterIDs.subtracting(existing)
    var added = 0
    for testerID in missing.sorted() {
        try ensureInternalTesterCanSeeApp(api, testerID: testerID, appID: everwhileApp)
        Thread.sleep(forTimeInterval: 2)
        let body: [String: Any] = [
            "data": [["type": "betaTesters", "id": testerID]]
        ]
        _ = try api.request("POST", "betaGroups/\(targetGroupID)/relationships/betaTesters", body: body, expected: [204])
        added += 1
    }
    print("S00_TF_INTERNAL_TESTERS_READY total=\(sourceTesterIDs.count) newly_added=\(added)")

    let build = try buildID(api, appID: everwhileApp, buildNumber: buildNumber)
    let linkedGroups = try betaGroupIDsForBuild(api, buildID: build)
    if !linkedGroups.contains(targetGroupID) {
        let body: [String: Any] = [
            "data": [["type": "betaGroups", "id": targetGroupID]]
        ]
        _ = try api.request("POST", "builds/\(build)/relationships/betaGroups", body: body, expected: [204])
        print("S00_TF_BUILD_ADDED_TO_INTERNAL_GROUP build=\(buildNumber)")
    } else {
        print("S00_TF_BUILD_ALREADY_IN_INTERNAL_GROUP build=\(buildNumber)")
    }

    print("S00_TF_INTERNAL_ACCESS_READY build=\(buildNumber)")
} catch let error as ASCError {
    print("S00_TF_INTERNAL_ACCESS_FAILED " + error.message)
    exit(1)
} catch {
    print("S00_TF_INTERNAL_ACCESS_FAILED unexpected")
    exit(1)
}
