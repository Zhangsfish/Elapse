// Existing RC readback only. GET requests, fixed app/version/build, allowlisted output.
// No upload, metadata mutation, review submission, private contacts or API IDs logged.
import CryptoKit
import Foundation

struct ReadbackError: Error {}
func base64URL(_ data: Data) -> String {
    data.base64EncodedString().replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
}
func bearer(_ key: P256.Signing.PrivateKey, _ keyID: String, _ issuer: String) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let header = ["alg": "ES256", "kid": keyID, "typ": "JWT"]
    let claims: [String: Any] = ["iss": issuer, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"]
    let body = base64URL(try JSONSerialization.data(withJSONObject: header)) + "." +
        base64URL(try JSONSerialization.data(withJSONObject: claims))
    return body + "." + base64URL(try key.signature(for: Data(body.utf8)).rawRepresentation)
}
func get(_ path: String, _ query: [String: String] = [:], _ token: String) throws -> [String: Any] {
    var url = URLComponents(string: "https://api.appstoreconnect.apple.com/v1/" + path)!
    url.queryItems = query.sorted(by: { $0.key < $1.key }).map { URLQueryItem(name: $0.key, value: $0.value) }
    var request = URLRequest(url: url.url!)
    request.httpMethod = "GET"
    request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var result: Data?
    var status: Int?
    URLSession.shared.dataTask(with: request) { data, response, _ in
        result = data
        status = (response as? HTTPURLResponse)?.statusCode
        semaphore.signal()
    }.resume()
    guard semaphore.wait(timeout: .now() + 30) == .success, status == 200, let data = result,
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        // Safe code only, never the URL/API response/error body or authentication data.
        print("S03_ASC_GET_FAILED http=" + String(status ?? 0))
        throw ReadbackError()
    }
    return json
}
func list(_ json: [String: Any]) throws -> [[String: Any]] {
    guard let data = json["data"] as? [[String: Any]] else { throw ReadbackError() }
    return data
}
func emit(_ value: [String: Any]) throws {
    let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
    print("S03_ASC_SAFE " + String(decoding: data, as: UTF8.self))
}

do {
    guard CommandLine.arguments.count == 2,
          let keyID = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_KEY_ID"],
          let issuer = ProcessInfo.processInfo.environment["APP_STORE_CONNECT_ISSUER_ID"] else {
        throw ReadbackError()
    }
    let key = try P256.Signing.PrivateKey(pemRepresentation:
        String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8))
    let token = try bearer(key, keyID, issuer)
    let apps = try list(get("apps", ["filter[bundleId]": "com.zhangsfish.elapse", "limit": "2"], token))
    guard apps.count == 1, let appID = apps[0]["id"] as? String,
          let appAttributes = apps[0]["attributes"] as? [String: Any],
          appAttributes["name"] as? String == "Everwhile" else { throw ReadbackError() }
    let builds = try list(get("builds", ["filter[app]": appID, "filter[version]": "92.1", "limit": "2"], token))
    guard builds.count == 1, let buildID = builds[0]["id"] as? String,
          let b = builds[0]["attributes"] as? [String: Any] else { throw ReadbackError() }
    let prerelease = try get("builds/" + buildID + "/preReleaseVersion", [:], token)
    let prereleaseAttributes = (prerelease["data"] as? [String: Any])?["attributes"] as? [String: Any]
    let version = prereleaseAttributes?["version"] as? String ?? "UNKNOWN"
    try emit(["app": "Everwhile", "bundle": "com.zhangsfish.elapse", "version": version,
              "build": b["version"] as? String ?? "UNKNOWN",
              "processingState": b["processingState"] as? String ?? "UNKNOWN",
              "buildAudienceType": b["buildAudienceType"] as? String ?? "UNKNOWN",
              "usesNonExemptEncryption": b["usesNonExemptEncryption"] ?? NSNull(),
              "expired": b["expired"] ?? NSNull(), "observedAt": ISO8601DateFormatter().string(from: Date())])
    guard version == "0.1.0", b["processingState"] as? String == "VALID",
          b["buildAudienceType"] as? String == "APP_STORE_ELIGIBLE" else { throw ReadbackError() }

    let versions = try list(get("apps/" + appID + "/appStoreVersions",
        ["filter[versionString]": "0.1.0", "filter[platform]": "IOS", "limit": "2"], token))
    if versions.count == 1, let itemID = versions[0]["id"] as? String,
       let v = versions[0]["attributes"] as? [String: Any] {
        let association = try get("appStoreVersions/" + itemID + "/build", [:], token)
        let associated = association["data"] as? [String: Any]
        try emit(["storeVersion": "0.1.0", "state": v["appStoreState"] as? String ?? "UNKNOWN",
                  "releaseType": v["releaseType"] as? String ?? "UNKNOWN",
                  "copyrightPresent": !(v["copyright"] as? String ?? "").isEmpty,
                  "build92_1Associated": associated?["id"] as? String == buildID,
                  "anyBuildAssociated": associated != nil])
        let localizations = try list(get("appStoreVersions/" + itemID + "/appStoreVersionLocalizations",
                                         ["limit": "50"], token))
        for item in localizations {
            guard let a = item["attributes"] as? [String: Any], let locale = a["locale"] as? String,
                  ["en-US", "zh-Hans"].contains(locale) else { continue }
            let promo = a["promotionalText"] as? String ?? ""
            let finalEnglish = "Choose the apps you want to notice and set a 5-minute interval. Everwhile sends reminders based on cumulative use and shows total, hourly, and per-app time in Today."
            try emit(["locale": locale, "promotionalTextCharacters": promo.count,
                      "englishPromotionalMatchesOwnerFinal": locale == "en-US" ? promo == finalEnglish : NSNull(),
                      "descriptionCharacters": (a["description"] as? String ?? "").count,
                      "keywordUTF8Bytes": (a["keywords"] as? String ?? "").utf8.count,
                      "supportURL": a["supportUrl"] as? String ?? "",
                      "marketingURLPresent": !(a["marketingUrl"] as? String ?? "").isEmpty])
        }
    } else {
        try emit(["storeVersion": "0.1.0", "state": "NO_UNIQUE_VERSION_RECORD"])
    }
    print("S03_ASC_EXISTING_RC_READBACK_PASS")
} catch {
    print("S03_ASC_READBACK_NOT_VERIFIED")
    exit(1)
}
