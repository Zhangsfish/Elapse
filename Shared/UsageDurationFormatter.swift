import Foundation

enum UsageDurationLanguage: Equatable {
    case english
    case simplifiedChinese

    static func forLocale(_ locale: Locale) -> Self {
        guard locale.language.languageCode?.identifier == "zh" else { return .english }
        // Respect explicit scripts before region inference. zh-Hant must not
        // silently become Simplified Chinese just because its language is zh.
        if let script = locale.language.script?.identifier {
            return script == "Hans" ? .simplifiedChinese : .english
        }
        return ["CN", "SG"].contains(locale.region?.identifier ?? "") ? .simplifiedChinese : .english
    }

    static func forBundle(_ bundle: Bundle = .main) -> Self {
        // Match the localization actually selected for UI resources, rather
        // than the user's potentially unsupported regional formatting locale.
        forLocale(Locale(identifier: bundle.preferredLocalizations.first ?? "en"))
    }
}

/// Display precision only. All aggregation and chart heights retain seconds.
enum UsageDurationFormatter {
    static func format(_ duration: TimeInterval, language: UsageDurationLanguage) -> String {
        guard duration.isFinite, duration > 0 else {
            return language == .simplifiedChinese ? "0分钟" : "0m"
        }
        guard duration >= 60 else {
            return language == .simplifiedChinese ? "<1分钟" : "<1m"
        }
        let wholeMinutes = Int(duration / 60)
        let hours = wholeMinutes / 60
        let minutes = wholeMinutes % 60
        switch language {
        case .english:
            return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        case .simplifiedChinese:
            return hours > 0 ? "\(hours)小时 \(minutes)分钟" : "\(minutes)分钟"
        }
    }
}
