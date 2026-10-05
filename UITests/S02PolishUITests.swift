import XCTest

/// Clean simulator UI only. No Screen Time entitlement/runtime claim or fake usage.
final class S02PolishUITests: XCTestCase {
    func testEnglishFirstVisitAndReplay() throws {
        try checkHome(language: "en", locale: "en_US", tagline: "Feel time passing. Nothing else.",
                      guideTitle: "Choose more than one app", expectsFirstVisit: true)
    }

    func testSimplifiedChineseReplayAtAccessibilitySize() throws {
        try checkHome(language: "zh-Hans", locale: "zh_CN", tagline: "感受时间流逝。仅此而已。",
                      guideTitle: "可以选择多个 App", expectsFirstVisit: false)
    }

    private func checkHome(language: String, locale: String, tagline: String, guideTitle: String,
                           expectsFirstVisit: Bool) throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launch()
        let skip = app.buttons["tutorial-skip"]
        if expectsFirstVisit {
            XCTAssertTrue(skip.waitForExistence(timeout: 15))
            XCTAssertTrue(skip.isHittable)
            attach(app, name: "\(language)-first-visit")
            XCTAssertFalse(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch.exists)
            skip.tap()
        }
        XCTAssertTrue(app.staticTexts[tagline].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["allow-screen-time"].exists)
        XCTAssertFalse(skip.exists)
        XCTAssertFalse(app.staticTexts["299"].exists)
        XCTAssertFalse(app.buttons["selection-tips"].exists)
        attach(app, name: "\(language)-home")

        let help = app.buttons["tutorial-replay"]
        XCTAssertTrue(help.isHittable)
        help.tap()
        XCTAssertTrue(app.staticTexts[guideTitle].waitForExistence(timeout: 5))
        let instruction = app.staticTexts["selection-guide-instruction"]
        for _ in 0..<4 where !instruction.isHittable { app.swipeUp() }
        XCTAssertTrue(instruction.exists)
        XCTAssertFalse(instruction.label.isEmpty)
        let done = app.buttons["tutorial-done"]
        XCTAssertTrue(done.isHittable, "Tutorial exit stays pinned even at large text")
        attach(app, name: "\(language)-replay")
        // Automated semantics/layout checks are not a human VoiceOver session.
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])
        done.tap()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["tutorial-skip"].exists, "Automatic tutorial must not repeat on relaunch")
        XCTAssertFalse(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch.exists)
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
