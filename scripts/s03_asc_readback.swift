// Default: GET only. Explicit --prepare-fields: public URLs, existing build association, reviewer notes.
// Never upload, submit, release, choose territories, log contacts/API IDs, or edit owner's listing copy.
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

func save(_ path: String, _ body: [String: Any], _ token: String) throws {
    // Only these resource classes; no submission/release/price/privacy-label endpoint.
    guard path.hasPrefix("appStoreVersionLocalizations/") || path.hasPrefix("appInfoLocalizations/") ||
          path.hasPrefix("appStoreReviewDetails/") ||
          (path.hasPrefix("appStoreVersions/") && path.hasSuffix("/relationships/build")) else { throw ReadbackError() }
    var request = URLRequest(url: URL(string: "https://api.appstoreconnect.apple.com/v1/" + path)!)
    request.httpMethod = "PATCH"
    request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let semaphore = DispatchSemaphore(value: 0)
    var status: Int?
    URLSession.shared.dataTask(with: request) { _, response, _ in
        status = (response as? HTTPURLResponse)?.statusCode
        semaphore.signal()
    }.resume()
    guard semaphore.wait(timeout: .now() + 30) == .success, [200, 204].contains(status ?? 0) else {
        print("S03_ASC_SAVE_FAILED http=" + String(status ?? 0))
        throw ReadbackError()
    }
}

do {
    let prepare = CommandLine.arguments.count == 3 && CommandLine.arguments[2] == "--prepare-fields"
    guard (CommandLine.arguments.count == 2 || prepare),
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
        var association = try get("appStoreVersions/" + itemID + "/build", [:], token)
        if prepare {
            guard v["appStoreState"] as? String == "PREPARE_FOR_SUBMISSION",
                  v["releaseType"] as? String == "MANUAL" else { throw ReadbackError() }
            let current = association["data"] as? [String: Any]
            guard current == nil || current?["id"] as? String == buildID else { throw ReadbackError() }
            if current == nil {
                try save("appStoreVersions/" + itemID + "/relationships/build",
                         ["data": ["type": "builds", "id": buildID]], token)
                association = try get("appStoreVersions/" + itemID + "/build", [:], token)
                guard (association["data"] as? [String: Any])?["id"] as? String == buildID else { throw ReadbackError() }
            }
        }
        let associated = association["data"] as? [String: Any]
        try emit(["storeVersion": "0.1.0", "state": v["appStoreState"] as? String ?? "UNKNOWN",
                  "releaseType": v["releaseType"] as? String ?? "UNKNOWN",
                  "copyrightPresent": !(v["copyright"] as? String ?? "").isEmpty,
                  "build92_1Associated": associated?["id"] as? String == buildID,
                  "anyBuildAssociated": associated != nil])
        let localizations = try list(get("appStoreVersions/" + itemID + "/appStoreVersionLocalizations",
                                         ["limit": "50"], token))
        for item in localizations {
            guard var a = item["attributes"] as? [String: Any], let locale = a["locale"] as? String,
                  ["en-US", "zh-Hans"].contains(locale) else { continue }
            if prepare, a["supportUrl"] as? String != "https://zhangsfish.github.io/Elapse/",
               let localizationID = item["id"] as? String {
                try save("appStoreVersionLocalizations/" + localizationID,
                         ["data": ["type": "appStoreVersionLocalizations", "id": localizationID,
                                   "attributes": ["supportUrl": "https://zhangsfish.github.io/Elapse/"]]], token)
                let refreshed = try get("appStoreVersionLocalizations/" + localizationID, [:], token)
                guard let fresh = (refreshed["data"] as? [String: Any])?["attributes"] as? [String: Any],
                      fresh["supportUrl"] as? String == "https://zhangsfish.github.io/Elapse/" else { throw ReadbackError() }
                a = fresh
            }
            let promo = a["promotionalText"] as? String ?? ""
            let finalEnglish = "Choose the apps you want to notice and set a 5-minute interval. Everwhile sends reminders based on cumulative use and shows total, hourly, and per-app time in Today."
            try emit(["locale": locale, "promotionalTextCharacters": promo.count,
                      "englishPromotionalMatchesOwnerFinal": locale == "en-US" ? promo == finalEnglish : NSNull(),
                      "descriptionCharacters": (a["description"] as? String ?? "").count,
                      "keywordUTF8Bytes": (a["keywords"] as? String ?? "").utf8.count,
                      "supportURL": a["supportUrl"] as? String ?? "",
                      "marketingURLPresent": !(a["marketingUrl"] as? String ?? "").isEmpty])
            try emit(["publicStoreMetadata": true, "locale": locale, "promotionalText": promo,
                      "description": a["description"] as? String ?? "", "keywords": a["keywords"] as? String ?? ""])
        }
        // Never output private reviewer fields, only whether the existing UI fields are complete.
        if var details = try? get("appStoreVersions/" + itemID + "/appStoreReviewDetail", [:], token),
           let detailID = (details["data"] as? [String: Any])?["id"] as? String,
           var d = (details["data"] as? [String: Any])?["attributes"] as? [String: Any] {
            let notesFile = try String(contentsOfFile: "docs/APP_REVIEW_NOTES.md", encoding: .utf8)
            guard notesFile.contains("## English reviewer notes\n"), notesFile.contains("## 简体中文审核备注") else { throw ReadbackError() }
            let notes = notesFile.components(separatedBy: "## English reviewer notes\n")[1]
                .components(separatedBy: "## 简体中文审核备注")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !notes.isEmpty, notes.count <= 4000 else { throw ReadbackError() }
            if prepare, d["notes"] as? String != notes {
                try save("appStoreReviewDetails/" + detailID,
                         ["data": ["type": "appStoreReviewDetails", "id": detailID,
                                   "attributes": ["notes": notes]]], token)
                details = try get("appStoreReviewDetails/" + detailID, [:], token)
                guard let fresh = (details["data"] as? [String: Any])?["attributes"] as? [String: Any] else { throw ReadbackError() }
                d = fresh
            }
            if prepare { guard d["notes"] as? String == notes else { throw ReadbackError() } }
            try emit(["reviewContactComplete": ["contactFirstName", "contactLastName", "contactEmail", "contactPhone"]
                .allSatisfy { !(d[$0] as? String ?? "").isEmpty },
                      "demoAccountRequired": d["demoAccountRequired"] ?? NSNull(),
                      "reviewNotesMatchRepository": d["notes"] as? String == notes,
                      "reviewNotesCharacters": notes.count])
        } else { try emit(["reviewContactReadback": "NOT_VERIFIED"]) }
    } else {
        try emit(["storeVersion": "0.1.0", "state": "NO_UNIQUE_VERSION_RECORD"])
    }
    let infos = try list(get("apps/" + appID + "/appInfos", ["limit": "10"], token))
    for info in infos {
        guard let infoID = info["id"] as? String, let infoAttrs = info["attributes"] as? [String: Any],
              infoAttrs["appStoreState"] as? String == "PREPARE_FOR_SUBMISSION" else { continue }
        let localizations = try list(get("appInfos/" + infoID + "/appInfoLocalizations", ["limit": "50"], token))
        for item in localizations {
            guard var a = item["attributes"] as? [String: Any], let locale = a["locale"] as? String,
                  ["en-US", "zh-Hans"].contains(locale) else { continue }
            if prepare, a["privacyPolicyUrl"] as? String != "https://zhangsfish.github.io/Elapse/privacy.html",
               let localizationID = item["id"] as? String {
                try save("appInfoLocalizations/" + localizationID,
                         ["data": ["type": "appInfoLocalizations", "id": localizationID,
                                   "attributes": ["privacyPolicyUrl": "https://zhangsfish.github.io/Elapse/privacy.html"]]], token)
                let refreshed = try get("appInfoLocalizations/" + localizationID, [:], token)
                guard let fresh = (refreshed["data"] as? [String: Any])?["attributes"] as? [String: Any],
                      fresh["privacyPolicyUrl"] as? String == "https://zhangsfish.github.io/Elapse/privacy.html" else { throw ReadbackError() }
                a = fresh
            }
            try emit(["publicAppInfo": true, "locale": locale, "name": a["name"] as? String ?? "",
                      "subtitle": a["subtitle"] as? String ?? "", "privacyPolicyURL": a["privacyPolicyUrl"] as? String ?? ""])
        }
    }
    print("S03_ASC_EXISTING_RC_READBACK_PASS")
} catch {
    print("S03_ASC_READBACK_NOT_VERIFIED")
    exit(1)
}
