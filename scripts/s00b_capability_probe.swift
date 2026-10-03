// Read-only App Store Connect capability probe. Prints only fixed statuses.
// The API does not prove that a specific App Group is registered/associated.
import CryptoKit
import Foundation

struct ProbeError: Error {
    let status: String
}

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
        "iss": issuerID, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1",
    ]
    let body = base64URL(try JSONSerialization.data(withJSONObject: header)) + "." +
        base64URL(try JSONSerialization.data(withJSONObject: claims))
    let signature = try key.signature(for: Data(body.utf8))
    return body + "." + base64URL(signature.rawRepresentation)
}

func readJSON(_ path: String, queries: [URLQueryItem], bearer: String) throws -> [[String: Any]] {
    var components = URLComponents(string: "https://api.appstoreconnect.apple.com/v1/" + path)!
    components.queryItems = queries
    var request = URLRequest(url: components.url!)
    request.setValue("Bearer " + bearer, forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var data: Data?
    var response: URLResponse?
    URLSession.shared.dataTask(with: request) { resultData, resultResponse, _ in
        data = resultData
        response = resultResponse
        semaphore.signal()
    }.resume()
    guard semaphore.wait(timeout: .now() + 30) == .success else {
        throw ProbeError(status: "TIMEOUT")
    }
    guard let http = response as? HTTPURLResponse else {
        throw ProbeError(status: "NETWORK_ERROR")
    }
    guard http.statusCode == 200 else {
        let safe = [401, 403, 404, 429].contains(http.statusCode) ? "HTTP_\(http.statusCode)" : "HTTP_OTHER"
        throw ProbeError(status: safe)
    }
    guard let data,
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let items = json["data"] as? [[String: Any]] else {
        throw ProbeError(status: "PARSE_ERROR")
    }
    return items
}

let arguments = CommandLine.arguments
guard arguments.count == 2,
      let keyID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_KEY_ID"],
      let issuerID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_ISSUER_ID"] else {
    print("S00B_CAPABILITY_PROBE=CONFIGURATION_ERROR")
    exit(1)
}

do {
    let key = try P256.Signing.PrivateKey(
        pemRepresentation: String(contentsOfFile: arguments[1], encoding: .utf8)
    )
    let bearer = try token(key: key, keyID: keyID, issuerID: issuerID)
    var foundAll = true
    for (label, identifier) in [
        ("APP", "com.zhangsfish.elapse"),
        ("MONITOR", "com.zhangsfish.elapse.monitor"),
    ] {
        let bundles = try readJSON(
            "bundleIds",
            queries: [URLQueryItem(name: "filter[identifier]", value: identifier)],
            bearer: bearer
        )
        // Some API-key scopes return an empty filtered list rather than an
        // authorization error. Cross-check the unfiltered first page without
        // logging any unrelated bundle identifiers.
        let candidates: [[String: Any]]
        if bundles.count == 1 {
            candidates = bundles
        } else {
            print("S00B_\(label)_FILTER_MATCH_COUNT=\(bundles.count)")
            let listed = try readJSON(
                "bundleIds",
                queries: [URLQueryItem(name: "limit", value: "200")],
                bearer: bearer
            )
            print("S00B_\(label)_UNFILTERED_LIST_COUNT=\(listed.count)")
            candidates = listed.filter { item in
                let attributes = item["attributes"] as? [String: Any]
                return attributes?["identifier"] as? String == identifier
            }
        }
        guard candidates.count == 1, let id = candidates[0]["id"] as? String else {
            print("S00B_\(label)_BUNDLE_IN_API=NOT_FOUND")
            foundAll = false
            continue
        }
        print("S00B_\(label)_BUNDLE_IN_API=FOUND")
        let capabilities = try readJSON(
            "bundleIds/" + id + "/bundleIdCapabilities",
            queries: [],
            bearer: bearer
        )
        let enabled = capabilities.contains { item in
            let attributes = item["attributes"] as? [String: Any]
            return attributes?["capabilityType"] as? String == "APP_GROUPS"
        }
        print("S00B_\(label)_APP_GROUPS_CAPABILITY=" + (enabled ? "ENABLED" : "MISSING"))
    }
    print("S00B_ASC_API_READ=" + (foundAll ? "PASS" : "BUNDLE_NOT_FOUND"))
    print("S00B_SPECIFIC_GROUP_REGISTRATION=UNVERIFIED_BY_THIS_API")
    if !foundAll { exit(1) }
} catch let error as ProbeError {
    print("S00B_ASC_API_READ=" + error.status)
    exit(1)
} catch {
    print("S00B_ASC_API_READ=UNEXPECTED_ERROR")
    exit(1)
}
