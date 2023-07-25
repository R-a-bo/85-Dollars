//
//  DatesHelperTests.swift
//  85 DollarsTests
//
//  Created by George Birch on 7/20/23.
//

import XCTest
@testable import _5_Dollars

final class DatesHelperTests: XCTestCase {
    
    let testSchedules = [
        Schedule(),
        Schedule(weekdays: [Weekday.Friday], weeks: [Rotation.First], alarms: [Alarm(daysInAdvance: 2, hour: 5, minute: 30)]),
        Schedule(weekdays: [Weekday.Thursday], weeks: [Rotation.First, Rotation.Second, Rotation.Third, Rotation.Fourth, Rotation.Fifth], alarms: [Alarm(daysInAdvance: 0, hour: 0, minute: 0)]),
        Schedule(weekdays: [Weekday.Thursday], weeks: [Rotation.First])
    ]
    
    override class func setUp() {
        DatesHelper.currentDate = { return Date(timeIntervalSince1970: 0) }
        DatesHelper.calendar = Calendar(identifier: .gregorian)
        DatesHelper.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        DatesHelper.notificationCenter = MockNotificationCenter()
    }
    
    override class func tearDown() {
        DatesHelper.currentDate = { return Date() }
        DatesHelper.calendar = Calendar(identifier: .gregorian)
        DatesHelper.notificationCenter = UNUserNotificationCenter.current()
    }

    func testDaysUntilCleaning() {
        XCTAssertEqual(DatesHelper.daysUntilCleaning(for: testSchedules[0]), nil)
        XCTAssertEqual(DatesHelper.daysUntilCleaning(for: testSchedules[1]), 1)
        XCTAssertEqual(DatesHelper.daysUntilCleaning(for: testSchedules[2]), 7)
        XCTAssertEqual(DatesHelper.daysUntilCleaning(for: testSchedules[3]), 35)
    }
    
    func testGetCleaningDays() {
        XCTAssertEqual(DatesHelper.getCleaningDays(for: testSchedules[0], in: 7, of: 2023), Set<DateComponents>())
        XCTAssertEqual(DatesHelper.getCleaningDays(for: testSchedules[1], in: 7, of: 2023), Set([DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 7, day: 7)]))
        XCTAssertEqual(DatesHelper.getCleaningDays(for: testSchedules[2], in: 8, of: 2023), Set([
            DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 8, day: 3), DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 8, day: 10), DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 8, day: 17), DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 8, day: 24),
            DateComponents(calendar: DatesHelper.calendar, era: 1, year: 2023, month: 8, day: 31)]))
    }
    
    func testGenerateNextAlarmDay() {
        XCTAssertEqual(DatesHelper.generateNextAlarmDay(for: Alarm(daysInAdvance: 0, hour: 0, minute: 0), in: testSchedules[0]), nil)
        XCTAssertEqual(DatesHelper.generateNextAlarmDay(for: testSchedules[1].alarms[0], in: testSchedules[1]), DateComponents(calendar: DatesHelper.calendar, era: 1, year: 1969, month: 12, day: 31, hour: 5, minute: 30))
        XCTAssertEqual(DatesHelper.generateNextAlarmDay(for: testSchedules[2].alarms[0], in: testSchedules[2]), DateComponents(calendar: DatesHelper.calendar, era: 1, year: 1970, month: 1, day: 8, hour: 0, minute: 0))
    }
    
    func testSetAlarms() {
        guard let center = DatesHelper.notificationCenter as? MockNotificationCenter else { return }
        var expectedContent = UNMutableNotificationContent()
        expectedContent.title = "Move your car!"
        expectedContent.sound = UNNotificationSound.default
        
        DatesHelper.setAlarms(for: testSchedules[0])
        XCTAssertEqual(center.requests.count, 0)
        
        DatesHelper.setAlarms(for: testSchedules[1])
        expectedContent.body = "You have street cleaning in 2 days"
        XCTAssertEqual(center.requests.first?.content, expectedContent)
        XCTAssertEqual(center.requests.first?.trigger, UNCalendarNotificationTrigger(dateMatching: DateComponents(calendar: DatesHelper.calendar, era: 1, year: 1969, month: 12, day: 31, hour: 5, minute: 30), repeats: false))
        XCTAssertEqual(center.requests.count, 1)
        
        DatesHelper.setAlarms(for: testSchedules[2])
        expectedContent.body = "You have street cleaning in 0 days"
        XCTAssertEqual(center.requests.first?.content, expectedContent)
        XCTAssertEqual(center.requests.first?.trigger, UNCalendarNotificationTrigger(dateMatching: DateComponents(calendar: DatesHelper.calendar, era: 1, year: 1970, month: 1, day: 8, hour: 0, minute: 0), repeats: false))
        XCTAssertEqual(center.requests.count, 1)
    }

}

class MockNotificationCenter: UserNotificationCenter {
    
    var authorizationRequested = false
    var grantAuthorization = true
    var error: Error? = nil
    
    var requests = Set<UNNotificationRequest>()
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        authorizationRequested = true
        completionHandler(grantAuthorization, error)
    }
    
    func removeAllPendingNotificationRequests() {
        requests.removeAll()
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        requests.insert(request)
        completionHandler?(error)
    }
    
}
