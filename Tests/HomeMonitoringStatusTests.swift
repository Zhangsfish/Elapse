import XCTest
@testable import ElapseCore

final class HomeMonitoringStatusTests: XCTestCase {
    func testStatePrecedenceAndNoRegistrationOverclaim() {
        func status(_ auth: Bool, _ count: Int, _ desired: Bool, _ exact: Bool, _ active: Bool, _ today: Bool, _ failed: Bool = false) -> HomeMonitoringStatus {
            .resolve(authorized: auth, selectedAppCount: count, desired: desired, exactRegistration: exact, intervalActive: active, intervalCycleIsToday: today, registrationFailed: failed)
        }
        XCTAssertEqual(status(false, 2, true, true, true, true), .needsPermission)
        XCTAssertEqual(status(true, 0, false, false, false, false), .needsApps)
        XCTAssertEqual(status(true, 2, false, false, false, false), .off)
        XCTAssertEqual(status(true, 2, true, true, true, true), .on)
        XCTAssertEqual(status(true, 2, true, true, false, true), .checking)
        XCTAssertEqual(status(true, 2, true, true, true, false), .checking)
        XCTAssertEqual(status(true, 2, true, false, true, true), .checking)
        XCTAssertEqual(status(true, 2, true, false, false, false, true), .needsAttention)
    }
}
