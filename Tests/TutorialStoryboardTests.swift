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
        XCTAssertEqual(TutorialFrame(time: 0).selection(0), 0)
        XCTAssertGreaterThan(TutorialFrame(time: 0.7).selection(0), 0)
        XCTAssertLessThan(TutorialFrame(time: 0.7).selection(0), 1)
        XCTAssertEqual(TutorialFrame(time: 0.7).selection(1), 0)
        XCTAssertEqual(TutorialFrame(time: 1.7).selection(1), 1)
        XCTAssertEqual(TutorialFrame(time: 3).selection(2), 0)
        XCTAssertEqual(TutorialFrame(time: 1.5).selectionConfirmation, 0)
        XCTAssertEqual(TutorialFrame(time: 3).selectionConfirmation, 1)
        XCTAssertEqual(TutorialFrame(time: 1).intervalSelection, 1)
        XCTAssertEqual(TutorialFrame(time: 1).monitoringProgress, 0)
        XCTAssertEqual(TutorialFrame(time: 3).monitoringProgress, 1)
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
        XCTAssertEqual(final.reportProgress, 1)
        XCTAssertEqual(final.totalOpacity, 1)
        XCTAssertEqual(final.bannerPosition, 1)
        for index in 0..<8 { XCTAssertEqual(final.barGrowth(index), 1) }
        for index in 0..<2 { XCTAssertEqual(final.rowAppearance(index), 1) }
        XCTAssertEqual(final.selectionHandOpacity, 0)
        XCTAssertEqual(final.intervalHandOpacity, 0)
    }
    func testEveryVisibleProgressIsContinuousAndBoundedAtSixtyHz() {
        func channels(_ frame: TutorialFrame) -> [Double] {
            [frame.selection(0), frame.selection(1), frame.selectionConfirmation,
             frame.intervalSelection, frame.intervalPress, frame.startPress,
             frame.monitoringProgress, frame.bannerOpacity, frame.reportProgress,
             frame.selectionHandOpacity, frame.intervalHandOpacity, frame.totalOpacity]
                + (0..<8).map { frame.barGrowth($0) } + (0..<2).map { frame.rowAppearance($0) }
        }
        var previous = channels(TutorialFrame(time: 0))
        for step in 1...180 {
            let current = channels(TutorialFrame(time: Double(step) / 60))
            for (old, new) in zip(previous, current) {
                XCTAssertTrue((0...1).contains(new))
                XCTAssertLessThan(abs(new - old), 0.15, "No boolean/step pop between adjacent frames")
            }
            previous = current
        }
    }
    func testPressReleaseSpringSettleAndStaggeredArrivals() {
        XCTAssertGreaterThan(TutorialFrame(time: 0.6).intervalPress, 0.5)
        XCTAssertEqual(TutorialFrame(time: 1).intervalPress, 0)
        XCTAssertGreaterThan(TutorialFrame(time: 1.65).startPress, 0.5)
        XCTAssertEqual(TutorialFrame(time: 3).startPress, 0)
        let mid = TutorialFrame(time: 1.35)
        XCTAssertGreaterThan(mid.barGrowth(0), mid.barGrowth(1))
        XCTAssertEqual(mid.barGrowth(7), 0)
        XCTAssertGreaterThan(TutorialFrame(time: 2.3).rowAppearance(0), TutorialFrame(time: 2.3).rowAppearance(1))
        XCTAssertEqual(TutorialFrame(time: 0).snap(from: 0.2, to: 0.9), 0)
        XCTAssertEqual(TutorialFrame(time: 3).snap(from: 0.2, to: 0.9), 1)
        var previous = TutorialFrame(time: 0).bannerPosition
        for step in 1...3000 {
            let frame = TutorialFrame(time: Double(step) / 1000)
            XCTAssertLessThan(abs(frame.bannerPosition - previous), 0.03)
            XCTAssertTrue((0...1.3).contains(frame.bannerPosition))
            XCTAssertTrue((104...188).contains(frame.selectionHandY))
            XCTAssertTrue((203...289).contains(frame.intervalHandY))
            previous = frame.bannerPosition
        }
    }
}
