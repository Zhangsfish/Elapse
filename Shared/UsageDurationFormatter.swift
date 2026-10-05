import Foundation

enum UsageDurationLanguage: Equatable {
    case english
    case simplifiedChinese

    static func forLocale(_ locale: Locale) -> Self {
        locale.language.languageCode?.identifier == "zh" ? .simplifiedChinese : .english
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
