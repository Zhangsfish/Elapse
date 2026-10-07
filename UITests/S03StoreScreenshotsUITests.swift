import XCTest

/// Capture the shipped Release home/tutorial only. No injected app tokens,
/// authorization, usage, notification history or screenshot-only runtime flags.
final class S03StoreScreenshotsUITests: XCTestCase {
    @MainActor
    func testEnglishStoreScreens() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["tutorial-skip"].waitForExistence(timeout: 20),
                      "This lane requires a fresh simulator and genuine first visit")
        XCTAssertTrue(app.staticTexts["Choose your apps"].waitForExistence(timeout: 5))
        capture(app, "02-choose-interval")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["Set an interval. Start."].waitForExistence(timeout: 5))
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["A quiet reminder"].waitForExistence(timeout: 5))
        capture(app, "03-reminder")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["See your time in Today"].waitForExistence(timeout: 5))
        capture(app, "04-today")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["tutorial-skip"].exists)
        XCTAssertFalse(app.buttons["developer-diagnostics"].exists)
        XCTAssertTrue(app.staticTexts["Screen Time access needed"].exists)
        capture(app, "01-awareness")
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        Thread.sleep(forTimeInterval: 3.4) // bounded shipped animation settles
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "store-en-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
