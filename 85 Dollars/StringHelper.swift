//
//  StringHelper.swift
//  85 Dollars
//
//  Created by George Birch on 7/19/23.
//

import UIKit

class StringHelper {
    
    static func string(for weeks: [Rotation]) -> String {
        if weeks.count == 4 {
            return "Every week"
        }
        var rotationString = "of the month"
        for (i, week) in weeks.enumerated().reversed() {
            if i < weeks.count - 2 {
                rotationString = "\(week), \(rotationString)"
            } else if i == weeks.count - 2 {
                rotationString = "\(week) and \(rotationString)"
            } else {
                rotationString = "\(week) \(rotationString)"
            }
        }
        return rotationString
    }
    
    static func string(for weekdays: [Weekday], isTruncated: Bool) -> String {
        if weekdays.count == 7 {
            return "Every day"
        }
        var result = ""
        for (i, day) in weekdays.enumerated().reversed() {
            let dayString = isTruncated ? day.truncated() : "\(day)"
            if i < weekdays.count - 2 {
                result = "\(dayString), \(result)"
            } else if i == weekdays.count - 2 {
                result = "\(dayString) and \(result)"
            } else {
                result = "\(dayString) \(result)"
            }
        }
        return result
    }
    
    static func string(for schedule: Schedule) -> NSMutableAttributedString {
        let weekdaysText = string(for: schedule.weekdays, isTruncated: true)
        let rotationText = string(for: schedule.weeks)
        let scheduleText = NSMutableAttributedString.init(string: "\(weekdaysText)\n\(rotationText)")
        scheduleText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, weekdaysText.count))
        return scheduleText
    }
    
    static func string(for alarm: Alarm) -> String {
        // can be done with DateFormatter, this allows us to avoid unnecessary complexity though
        let hourString = "\(alarm.hour % 12 == 0 ? 12 : alarm.hour % 12)"
        let minuteString = "\(alarm.minute < 10 ? "0" : "")\(alarm.minute)"
        let daysString = "\(alarm.daysInAdvance) \(alarm.daysInAdvance == 1 ? "day" : "days") before cleaning"
        return "\(hourString):\(minuteString) \(alarm.hour >= 12 ? "PM" : "AM"), \(daysString)"
    }
    
}
