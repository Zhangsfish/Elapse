import Foundation
import XCTest
@testable import ElapseCore

final class S02PolishTests: XCTestCase {
    func testReturningUsersDoNotGetInlineTeaching() {
        XCTAssertTrue(AppSelectionTeaching.showInline(authorized: true, selectedAppCount: 0, canChangeSelection: true))
        XCTAssertFalse(AppSelectionTeaching.showInline(authorized: false, selectedAppCount: 0, canChangeSelection: true))
        XCTAssertFalse(AppSelectionTeaching.showInline(authorized: true, selectedAppCount: 0, canChangeSelection: false))
        for count in [1, 2, 5] {
            XCTAssertFalse(AppSelectionTeaching.showInline(authorized: true, selectedAppCount: count, canChangeSelection: true))
        }
    }

    func testTeachingAnimationRespectsReduceMotionAndVoiceOver() {
        XCTAssertTrue(AppSelectionTeaching.shouldAnimate(reduceMotion: false, voiceOver: false))
        XCTAssertFalse(AppSelectionTeaching.shouldAnimate(reduceMotion: true, voiceOver: false))
        XCTAssertFalse(AppSelectionTeaching.shouldAnimate(reduceMotion: false, voiceOver: true))
        XCTAssertFalse(AppSelectionTeaching.shouldAnimate(reduceMotion: true, voiceOver: true))
    }

    func testLocaleScriptsAndUnsupportedFallback() {
        for identifier in ["zh-Hans", "zh_Hans_CN", "zh-CN", "zh-SG"] {
            XCTAssertEqual(UsageDurationLanguage.forLocale(Locale(identifier: identifier)), .simplifiedChinese, identifier)
        }
        for identifier in ["en", "en-GB", "zh-Hant", "zh_Hant_CN", "zh-TW", "zh-HK", "ja-JP", "fr-FR"] {
            XCTAssertEqual(UsageDurationLanguage.forLocale(Locale(identifier: identifier)), .english, identifier)
        }
    }

    func testBilingualThresholdCopyUsesActualThresholdWithoutTodayOrJudgment() {
        for minutes in [5, 10, 15, 30, 60, 720, 1495] {
            let english = PulseNotificationCopy.safeThresholdCopy(minutes: minutes, language: .english)
            XCTAssertEqual(english.title, "\(minutes) minutes")
            XCTAssertEqual(english.body, "Selected apps reached the \(minutes)-minute reminder point.")
            let chinese = PulseNotificationCopy.safeThresholdCopy(minutes: minutes, language: .simplifiedChinese)
            XCTAssertEqual(chinese.title, "\(minutes) 分钟")
            XCTAssertEqual(chinese.body, "所选 App 已达到 \(minutes) 分钟提醒点。")
            for copy in [english, chinese] {
                for unsafe in ["today", "passed", "wasted", "stop", "今天", "浪费", "该停"] {
                    XCTAssertFalse(copy.body.contains(unsafe))
                }
            }
        }
    }

    func testPackagedNotificationResourcesMatchPureCopyInBothLanguages() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        for (identifier, language) in [("en", UsageDurationLanguage.english), ("zh-Hans", .simplifiedChinese)] {
            let bundle = try XCTUnwrap(Bundle(path: root.appendingPathComponent("Localization/\(identifier).lproj").path))
            for minutes in [5, 15, 60, 1495] {
                XCTAssertEqual(PulseNotificationCopy.localizedThresholdCopy(minutes: minutes, bundle: bundle),
                               PulseNotificationCopy.safeThresholdCopy(minutes: minutes, language: language))
            }
        }
    }

    func testMissingNotificationResourcesFailToSafeEnglish() {
        XCTAssertEqual(PulseNotificationCopy.localizedThresholdCopy(minutes: 30, bundle: Bundle(for: Self.self)),
                       PulseNotificationCopy.safeThresholdCopy(minutes: 30, language: .english))
    }
}
