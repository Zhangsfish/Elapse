import Foundation
import XCTest
@testable import ElapseCore

final class UsageDurationFormatterTests: XCTestCase {
    func testEnglishPrecisionBoundaries() {
        let cases: [(TimeInterval, String)] = [
            (0, "0m"), (1, "<1m"), (59, "<1m"), (60, "1m"),
            (3599, "59m"), (3600, "1h 0m"), (3720, "1h 2m")
        ]
        for (seconds, expected) in cases {
            XCTAssertEqual(UsageDurationFormatter.format(seconds, language: .english), expected)
        }
    }

    func testSimplifiedChinesePrecisionAndLocale() {
        XCTAssertEqual(UsageDurationFormatter.format(1, language: .simplifiedChinese), "<1分钟")
        XCTAssertEqual(UsageDurationFormatter.format(3720, language: .simplifiedChinese), "1小时 2分钟")
        XCTAssertEqual(UsageDurationLanguage.forLocale(Locale(identifier: "zh_Hans_CN")), .simplifiedChinese)
        XCTAssertEqual(UsageDurationLanguage.forLocale(Locale(identifier: "en_US")), .english)
    }
}
