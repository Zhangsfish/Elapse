import XCTest
@testable import ElapseCore

final class TutorialStoryboardTests: XCTestCase {
    func testFourScenesHaveBoundedNavigationAndDistinctLocalizedMeaning() {
        XCTAssertEqual(TutorialScene.allCases.count, 4)
        XCTAssertEqual(TutorialScene.chooseApps.previous, .chooseApps)
        XCTAssertEqual(TutorialScene.today.next, .today)
        XCTAssertEqual(TutorialScene.chooseApps.next.next.next, .today)
        XCTAssertEqual(TutorialScene.today.previous, .reminder)
        XCTAssertEqual(Set(TutorialScene.allCases.map(\.titleKey)).count, 4)
        XCTAssertEqual(Set(TutorialScene.allCases.map(\.voiceKey)).count, 4)
    }
    func testFramesAreBoundedAndInvalidTimeFailsToInitialFrame() {
        XCTAssertEqual(TutorialFrame(time: -1).time, 0)
        XCTAssertEqual(TutorialFrame(time: 100).time, TutorialFrame.duration)
        for value in [Double.nan, .infinity, -.infinity] {
            XCTAssertEqual(TutorialFrame(time: value), TutorialFrame(time: 0))
        }
    }
    func testSelectionAndStartFollowTheDemonstratedOrder() {
        XCTAssertEqual(TutorialFrame(time: 0).selectedRows, 0)
        XCTAssertEqual(TutorialFrame(time: 0.8).selectedRows, 1)
        XCTAssertEqual(TutorialFrame(time: 1.5).selectedRows, 2)
        XCTAssertFalse(TutorialFrame(time: 1.5).selectionConfirmed)
        XCTAssertTrue(TutorialFrame(time: 3).selectionConfirmed)
        XCTAssertTrue(TutorialFrame(time: 1).intervalChosen)
        XCTAssertFalse(TutorialFrame(time: 1).monitoringOn)
        XCTAssertTrue(TutorialFrame(time: 3).monitoringOn)
    }
    func testSharedPoolReachesEndBeforeBannerAndSettledFrameIsComplete() {
        var previous = 0.0
        for time in stride(from: 0.0, through: 3.0, by: 0.1) {
            let frame = TutorialFrame(time: time)
            XCTAssertGreaterThanOrEqual(frame.sharedUsageProgress, previous)
            XCTAssertLessThanOrEqual(frame.sharedUsageProgress, 1)
            if frame.sharedUsageProgress < 1 { XCTAssertEqual(frame.bannerOpacity, 0) }
            previous = frame.sharedUsageProgress
        }
        let final = TutorialFrame(time: TutorialFrame.duration)
        XCTAssertEqual(final.bannerOpacity, 1)
        XCTAssertTrue(final.reportOpened)
        XCTAssertEqual(final.totalOpacity, 1)
        XCTAssertEqual(final.hourlyOpacity, 1)
        XCTAssertEqual(final.appRowsOpacity, 1)
    }
}
