import XCTest

/// Clean simulator UI only. No Screen Time entitlement/runtime claim or fake usage.
final class S02PolishUITests: XCTestCase {
    func testEnglishHomeAndOptionalTeaching() throws {
        try checkHome(language: "en", locale: "en_US", tagline: "Feel time passing. Nothing else.",
                      guideTitle: "Choose more than one app")
    }

    func testSimplifiedChineseHomeAtAccessibilitySize() throws {
        try checkHome(language: "zh-Hans", locale: "zh_CN", tagline: "感受时间流逝。仅此而已。",
                      guideTitle: "可以选择多个 App")
    }

    private func checkHome(language: String, locale: String, tagline: String, guideTitle: String) throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launch()
        XCTAssertTrue(app.staticTexts[tagline].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["allow-screen-time"].exists)
        XCTAssertFalse(app.staticTexts["299"].exists)
        attach(app, name: "\(language)-home")

        let help = app.buttons["selection-tips"]
        for _ in 0..<6 where !help.isHittable { app.swipeUp() }
        XCTAssertTrue(help.isHittable)
        help.tap()
        XCTAssertTrue(app.staticTexts[guideTitle].waitForExistence(timeout: 5))
        let instruction = app.staticTexts["selection-guide-instruction"]
        for _ in 0..<4 where !instruction.isHittable { app.swipeUp() }
        XCTAssertTrue(instruction.exists)
        XCTAssertFalse(instruction.label.isEmpty)
        attach(app, name: "\(language)-selection-guide")
        // Automated semantics/layout checks are not a human VoiceOver session.
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
