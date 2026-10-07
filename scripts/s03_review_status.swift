// Query one exact Everwhile App Store review candidate after upload.
// Never print tokens, raw API responses, account IDs, or private signing material.
import CryptoKit
import Foundation

struct APIError: Error {}

func base64URL(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func token(key: P256.Signing.PrivateKey, keyID: String, issuerID: String) throws -> String {
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

func requestJSON(_ path: String, queries: [URLQueryItem], bearer: String) throws -> [String: Any] {
    var url = URLComponents(string: "https://api.appstoreconnect.apple.com/v1/" + path)!
    url.queryItems = queries
    var request = URLRequest(url: url.url!)
    request.setValue("Bearer " + bearer, forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var responseData: Data?
    var response: URLResponse?
    var requestError: Error?
    URLSession.shared.dataTask(with: request) { data, result, error in
        responseData = data
        response = result
        requestError = error
        semaphore.signal()
    }.resume()
    guard semaphore.wait(timeout: .now() + 30) == .success,
          requestError == nil,
          let http = response as? HTTPURLResponse,
          http.statusCode == 200,
          let data = responseData,
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw APIError()
    }
    return json
}

func get(_ path: String, queries: [URLQueryItem], bearer: String) throws -> [[String: Any]] {
    guard let items = try requestJSON(path, queries: queries, bearer: bearer)["data"] as? [[String: Any]] else {
        throw APIError()
    }
    return items
}

let args = CommandLine.arguments
guard args.count == 3,
      let keyID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_KEY_ID"],
      let issuerID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_ISSUER_ID"] else {
    print("S03_RC_STATUS_NOT_VERIFIED configuration")
    exit(1)
}

do {
    let key = try P256.Signing.PrivateKey(
        pemRepresentation: String(contentsOfFile: args[1], encoding: .utf8)
    )
    let bearer = try token(key: key, keyID: keyID, issuerID: issuerID)
    let apps = try get(
        "apps",
        queries: [
            URLQueryItem(name: "filter[bundleId]", value: "com.zhangsfish.elapse"),
            URLQueryItem(name: "limit", value: "2"),
        ],
        bearer: bearer
    )
    guard apps.count == 1, let appID = apps.first?["id"] as? String else {
        throw APIError()
    }

    for attempt in 0..<30 {
        let builds = try get(
            "builds",
            queries: [
                URLQueryItem(name: "filter[app]", value: appID),
                URLQueryItem(name: "filter[version]", value: args[2]),
                URLQueryItem(name: "limit", value: "2"),
            ],
            bearer: try token(key: key, keyID: keyID, issuerID: issuerID)
        )
        if let item = builds.first,
           let attributes = item["attributes"] as? [String: Any],
           let state = attributes["processingState"] as? String {
            if state == "VALID" {
                let audience = attributes["buildAudienceType"] as? String ?? "UNKNOWN"
                print("S03_RC_PROCESSING_STATUS_VALID build=" + args[2])
                print("S03_RC_BUILD_AUDIENCE=" + audience)
                if let encryption = attributes["usesNonExemptEncryption"] as? Bool {
                    print("S03_RC_USES_NON_EXEMPT_ENCRYPTION=" + (encryption ? "TRUE" : "FALSE"))
                } else {
                    print("S03_RC_USES_NON_EXEMPT_ENCRYPTION=UNKNOWN")
                }
                guard audience == "APP_STORE_ELIGIBLE" else {
                    print("S03_RC_REVIEW_ELIGIBILITY=FAIL")
                    exit(1)
                }
                print("S03_RC_REVIEW_ELIGIBILITY=PASS")
                exit(0)
            }
            if state == "FAILED" || state == "INVALID" {
                print("S03_RC_PROCESSING_STATUS_" + state + " build=" + args[2])
                exit(1)
            }
        }
        if attempt < 29 {
            Thread.sleep(forTimeInterval: 30)
        }
    }
    print("S03_RC_PROCESSING_STATUS_PENDING build=" + args[2])
    exit(1)
} catch {
    print("S03_RC_STATUS_NOT_VERIFIED api_query_failed")
    exit(1)
}
