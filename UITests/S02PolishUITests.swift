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
        closeSupportAfterReplay(app)
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 5))
        XCTAssertFalse(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch.exists)
        // Replay always begins at scene one; Skip is usable immediately.
        replay(app)
        XCTAssertTrue(app.staticTexts[titles[0]].waitForExistence(timeout: 5))
        skip.tap()
        closeSupportAfterReplay(app)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 15))
        XCTAssertFalse(skip.exists, "Automatic tutorial does not repeat")
        try checkPublicSupport(app, language: language)
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func replay(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["home-menu"].isHittable)
        XCTAssertFalse(app.buttons["tutorial-replay"].exists, "Replay is inside About & Support only")
        app.buttons["home-menu"].tap()
        XCTAssertTrue(app.buttons["about-open"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tutorial-replay"].exists)
        app.buttons["about-open"].tap()
        XCTAssertTrue(app.buttons["about-tutorial-replay"].waitForExistence(timeout: 5))
        app.buttons["about-tutorial-replay"].tap()
    }

    private func closeSupportAfterReplay(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["about-close"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tutorial-skip"].exists)
        app.buttons["about-close"].tap()
    }

    /// Run on the real Release binary: no DEBUG settings or fake model state.
    private func checkPublicSupport(_ app: XCUIApplication, language: String) throws {
        let chinese = language == "zh-Hans"
        app.buttons["home-menu"].tap()
        XCTAssertTrue(app.buttons["about-open"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tutorial-replay"].exists)
        XCTAssertFalse(app.buttons["developer-diagnostics"].exists)
        for name in ["Advanced diagnostics", "Advanced Diagnostics", "Developer Diagnostics", "高级诊断", "开发者诊断"] {
            XCTAssertFalse(app.buttons[name].exists, "Release menu must not expose developer tools")
        }
        attach(app, name: "\(language)-release-menu")
        app.buttons["about-open"].tap()
        XCTAssertTrue(app.staticTexts[chinese ? "关于与支持" : "About & Support"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["about-close"].isHittable)
        XCTAssertLessThan(app.buttons["about-close"].frame.maxY, app.frame.height * 0.35,
                          "The support header stays at the top, not above a squeezed Form")
        XCTAssertTrue(app.buttons["about-tutorial-replay"].exists)
        attach(app, name: "\(language)-about-top")
        try auditSupport(app, scope: "\(language)-about-top")

        scrollTo(app.buttons["about-email"], in: app)
        let copy = app.buttons["about-copy-email"]
        scrollTo(copy, in: app)
        copy.tap()
        XCTAssertTrue(app.buttons[chinese ? "已复制" : "Copied"].waitForExistence(timeout: 2))
        scrollTo(app.buttons["about-homepage"], in: app)
        // Do not launch Mail/browser or send anything from a simulator test.
        let version = app.staticTexts["about-version"]
        scrollTo(version, in: app)
        XCTAssertFalse(app.staticTexts[chinese ? "无账号、无广告、无分析。" : "No account, no ads, no analytics."].exists)
        XCTAssertNotNil(version.label.range(of: #"^\d+\.\d+\.\d+ \(\d+(\.\d+)?\)$"#, options: .regularExpression))
        XCTAssertFalse(app.buttons["developer-diagnostics"].exists)
        attach(app, name: "\(language)-about-version")
        try auditSupport(app, scope: "\(language)-about-version")
        app.buttons["about-close"].tap()
        XCTAssertTrue(app.buttons["home-menu"].waitForExistence(timeout: 5))
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.exists && element.isHittable, "Form content must be reachable by scrolling")
    }

    private func auditSupport(_ app: XCUIApplication, scope: String) throws {
        try app.performAccessibilityAudit(for: [.dynamicType, .textClipped]) { issue in
            // Generic clean-simulator UI only. Never suppress a finding.
            print("S02B_SUPPORT_AUDIT_ISSUE scope=\(scope) type=\(issue.auditType) "
                  + "summary=\(issue.compactDescription) detail=\(issue.detailedDescription) "
                  + "element=\(issue.element?.debugDescription ?? "none")")
            return false
        }
    }
}
