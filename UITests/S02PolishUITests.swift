import XCTest

/// Native generic teaching only. No fake authorization or Screen Time usage.
final class S02PolishUITests: XCTestCase {
    func testEnglishFirstVisitAndReplay() throws {
        try checkTutorial(language: "en", locale: "en_US", tagline: "Feel time passing. Nothing else.",
                          titles: ["Choose your apps", "Set an interval. Start.",
                                   "A quiet reminder", "See your time in Today"], expectsFirstVisit: true)
    }

    func testSimplifiedChineseReplayAtAccessibilitySize() throws {
        try checkTutorial(language: "zh-Hans", locale: "zh_CN", tagline: "感受时间流逝。仅此而已。",
                          titles: ["选择 App", "设定间隔，开始", "轻轻提醒一下", "看看今日用时"],
                          expectsFirstVisit: false)
    }

    private func checkTutorial(language: String, locale: String, tagline: String,
                               titles: [String], expectsFirstVisit: Bool) throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launch()
        let skip = app.buttons["tutorial-skip"]
        if expectsFirstVisit {
            XCTAssertTrue(skip.waitForExistence(timeout: 15))
            XCTAssertTrue(skip.isHittable, "Skip never waits for animation")
            attach(app, name: "\(language)-first-visit")
            skip.tap()
        }
        XCTAssertTrue(app.staticTexts[tagline].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["allow-screen-time"].exists)
        XCTAssertFalse(skip.exists)
        XCTAssertFalse(app.staticTexts["299"].exists)
        attach(app, name: "\(language)-home")
        replay(app)
        let next = app.buttons["tutorial-next"]
        for index in titles.indices {
            XCTAssertTrue(app.staticTexts[titles[index]].waitForExistence(timeout: 5))
            XCTAssertTrue(next.isHittable)
            XCTAssertTrue(skip.isHittable)
            // Let the bounded playback settle, then inspect the same real artwork.
            Thread.sleep(forTimeInterval: 3.2)
            attach(app, name: "\(language)-scene-\(index + 1)")
            try app.performAccessibilityAudit(for: [.dynamicType, .textClipped])
            if index == 1 {
                app.buttons["tutorial-previous"].tap()
                XCTAssertTrue(app.staticTexts[titles[0]].waitForExistence(timeout: 5))
                XCTAssertTrue(next.isHittable, "Navigation does not wait for playback")
                next.tap()
                XCTAssertTrue(app.staticTexts[titles[1]].waitForExistence(timeout: 5))
            }
            next.tap()
        }
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 5))
        XCTAssertFalse(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch.exists)
        // Replay always begins at scene one; Skip is usable immediately.
        replay(app)
        XCTAssertTrue(app.staticTexts[titles[0]].waitForExistence(timeout: 5))
        skip.tap()
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 15))
        XCTAssertFalse(skip.exists, "Automatic tutorial does not repeat")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func replay(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["home-menu"].isHittable)
        XCTAssertFalse(app.buttons["tutorial-replay"].exists, "Replay is secondary, inside one menu")
        app.buttons["home-menu"].tap()
        XCTAssertTrue(app.buttons["tutorial-replay"].waitForExistence(timeout: 5))
        app.buttons["tutorial-replay"].tap()
    }
}
