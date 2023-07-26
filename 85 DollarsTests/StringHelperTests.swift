//
//  StringHelperTests.swift
//  85 DollarsTests
//
//  Created by George Birch on 7/19/23.
//

import XCTest
@testable import _5_Dollars

final class StringHelperTests: XCTestCase {

    func testRotationString() {
        XCTAssertEqual(StringHelper.string(for: [Rotation.First]), "1st of the month")
        XCTAssertEqual(StringHelper.string(for: [Rotation.Third, Rotation.Fourth]), "3rd and 4th of the month")
        XCTAssertEqual(StringHelper.string(for: [Rotation.Fifth]), "5th of the month")
        XCTAssertEqual(StringHelper.string(for: [Rotation.First, Rotation.Second, Rotation.Third, Rotation.Fourth, Rotation.Fifth]), "Every week")
        XCTAssertEqual(StringHelper.string(for: [Rotation.First, Rotation.Second, Rotation.Fourth]), "1st, 2nd and 4th of the month")
        XCTAssertEqual(StringHelper.string(for: [Rotation.First, Rotation.Second, Rotation.Third, Rotation.Fourth]), "1st, 2nd, 3rd and 4th of the month")
    }
    
    func testWeekdaysStringTruncated() {
        XCTAssertEqual(StringHelper.string(for: [Weekday.Sunday], isTruncated: true), "Sun ")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Monday, Weekday.Tuesday], isTruncated: true), "Mon and Tue ")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Sunday, Weekday.Monday, Weekday.Tuesday, Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], isTruncated: true), "Every day")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], isTruncated: true), "Wed, Thu, Fri and Sat ")
    }
    
    func testWeekdaysStringUntruncated() {
        XCTAssertEqual(StringHelper.string(for: [Weekday.Sunday], isTruncated: false), "Sunday ")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Monday, Weekday.Tuesday], isTruncated: false), "Monday and Tuesday ")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Sunday, Weekday.Monday, Weekday.Tuesday, Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], isTruncated: false), "Every day")
        XCTAssertEqual(StringHelper.string(for: [Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], isTruncated: false), "Wednesday, Thursday, Friday and Saturday ")
    }
    
    func testScheduleString() {
        var result = NSMutableAttributedString(string: "Mon \n4th of the month")
        result.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, 4))
        XCTAssertEqual(StringHelper.string(for: Schedule(weekdays: [Weekday.Monday], weeks: [Rotation.Fourth])), result)
        result = NSMutableAttributedString(string: "Mon and Wed \n2nd and 4th of the month")
        result.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, 12))
        XCTAssertEqual(StringHelper.string(for: Schedule(weekdays: [Weekday.Monday, Weekday.Wednesday], weeks: [Rotation.Second, Rotation.Fourth])), result)
        result = NSMutableAttributedString(string: "Mon, Wed and Fri \n2nd, 3rd and 4th of the month")
        result.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, 17))
        XCTAssertEqual(StringHelper.string(for: Schedule(weekdays: [Weekday.Monday, Weekday.Wednesday, Weekday.Friday], weeks: [Rotation.Second, Rotation.Third, Rotation.Fourth])), result)
        result = NSMutableAttributedString(string: "Every day\n1st, 2nd, 3rd and 4th of the month")
        result.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, 9))
        XCTAssertEqual(StringHelper.string(for: Schedule(weekdays: [Weekday.Sunday, Weekday.Monday, Weekday.Tuesday, Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], weeks: [Rotation.First, Rotation.Second, Rotation.Third, Rotation.Fourth])), result)
        result = NSMutableAttributedString(string: "Every day\nEvery week")
        result.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, 9))
        XCTAssertEqual(StringHelper.string(for: Schedule(weekdays: [Weekday.Sunday, Weekday.Monday, Weekday.Tuesday, Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday], weeks: [Rotation.First, Rotation.Second, Rotation.Third, Rotation.Fourth, Rotation.Fifth])), result)
    }
    
    func testAlarmString() {
        XCTAssertEqual(StringHelper.string(for: Alarm(daysInAdvance: 3, hour: 10, minute: 20)), "10:20 AM, 3 days before cleaning")
        XCTAssertEqual(StringHelper.string(for: Alarm(daysInAdvance: 0, hour: 20, minute: 0)), "8:00 PM, 0 days before cleaning")
    }

}
