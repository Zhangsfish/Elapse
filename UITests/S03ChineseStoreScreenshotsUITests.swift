import XCTest

/// Fresh Chinese Release captures of shipped UI only; no injected private state.
final class S03ChineseStoreScreenshotsUITests: XCTestCase {
    @MainActor
    func testChineseStoreScreens() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        XCTAssertTrue(app.buttons["tutorial-skip"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["选择 App"].waitForExistence(timeout: 5))
        capture(app, "02-choose-interval")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["设定间隔，开始"].waitForExistence(timeout: 5))
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["轻轻提醒一下"].waitForExistence(timeout: 5))
        capture(app, "03-reminder")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.staticTexts["看看今日用时"].waitForExistence(timeout: 5))
        capture(app, "04-today")
        app.buttons["tutorial-next"].tap()
        XCTAssertTrue(app.buttons["allow-screen-time"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["tutorial-skip"].waitForNonExistence(timeout: 5))
        XCTAssertFalse(app.buttons["developer-diagnostics"].exists)
        XCTAssertTrue(app.staticTexts["需要屏幕使用时间授权"].exists)
        capture(app, "01-awareness")
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        Thread.sleep(forTimeInterval: 3.4) // bounded shipped animation settles
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "store-zh-hans-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
