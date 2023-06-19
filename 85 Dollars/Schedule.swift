//
//  Schedule.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

struct Schedule: Codable {
    
    var weekdays: [Weekday]
    var weeks: [Rotation]
    var alarms: [Alarm]
    var hourOfDay: Int?
    var name: String?
    // stores a map from months (measured by difference from current) to sets of street cleaning days
    var cleaningDays = [Int: Set<DateComponents>]()
    
    func daysUntilCleaning() -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        let todayComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        guard let currentMonth = todayComponents.month, let currentYear = todayComponents.year else { return 0 }
        
        if let shortestDaysUntilCleaning = daysUntilCleaning(from: todayComponents, to: currentMonth, of: currentYear, accordingTo: calendar) {
            return shortestDaysUntilCleaning
        }
        
        let nextMonth = currentMonth == 12 ? 1 : currentMonth + 1
        let nextMonthYear = currentMonth == 12 ? currentYear + 1 : currentYear
        return daysUntilCleaning(from: todayComponents, to: nextMonth, of: nextMonthYear, accordingTo: calendar)
    }
    
    private func daysUntilCleaning(from todayComponents: DateComponents, to month: Int, of year: Int, accordingTo calendar: Calendar) -> Int? {
        let currentMonthCleaningDays = getCleaningDays(for: month, of: year)
        let timesUntilCleaning = currentMonthCleaningDays.map { (components) -> Int in
            let dateDifference = calendar.dateComponents([.day], from: todayComponents, to: components)
            return dateDifference.day ?? 0
        }.filter { $0 > 0 }
        return timesUntilCleaning.min()
    }
    
    // returns set of street cleaning days as DateComponents's for the given month
    func getCleaningDays(for month: Int, of year: Int) -> Set<DateComponents> {
        let calendar = Calendar(identifier: .gregorian)
        let currentMonth = calendar.dateComponents([.year, .month], from: Date())
        let monthsFromNowComponents = calendar.dateComponents([.month], from: DateComponents(year: currentMonth.year!, month: currentMonth.month!), to: DateComponents(year: year, month: month))
        
        guard let monthsFromNow = monthsFromNowComponents.month else { return Set<DateComponents>() }
        if let dates = cleaningDays[monthsFromNow] {
            return dates
        }
        
        var dates = Set<DateComponents>()
        
        var firstOfMonthComponents = DateComponents(year: year, month: month, day: 1)
        let firstOfMonthDate = calendar.date(from: firstOfMonthComponents)
        guard let firstOfMonthDate = firstOfMonthDate else { return dates }
        firstOfMonthComponents = calendar.dateComponents([.weekday], from: firstOfMonthDate)
        guard let weekdayOfFirst = firstOfMonthComponents.weekday else { return dates }
        
        for weekday in weekdays {
            let daysUntilWeekday = weekday.rawValue - weekdayOfFirst
            let nearbyWeekday = 1 + daysUntilWeekday
            var firstWeekdayOfMonth = (nearbyWeekday + 7) % 7
            firstWeekdayOfMonth = firstWeekdayOfMonth == 0 ? 7 : firstWeekdayOfMonth
            for week in weeks {
                let cleaningDay = DateComponents(calendar: calendar, era: 1, year: year, month: month, day: firstWeekdayOfMonth + week.rawValue * 7)
                dates.insert(cleaningDay)
            }
        }
        
        return dates
    }
    
    func weekdaysStringRepresentation(isTruncated: Bool) -> String {
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
    
    func rotationStringRepresentation() -> String {
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
    
    // old alarm string representation, made for alarms being time intervals before street cleaning
    // kept in case of future use when support for cleaning times is added
//    func alarmStringRepresentationOld(for alarm: Int) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .full
//        formatter.allowedUnits = [.day, .hour]
//        let result = formatter.string(from: alarms[alarm])
//        if let result = result {
//            return "\(result) before cleaning times"
//        } else {
//            print("Unable to generate string for alarm \(alarm) of \(alarms[alarm])")
//            return ""
//        }
//    }
    
    func scheduleTitle() -> NSMutableAttributedString {
        let weekdaysText = weekdaysStringRepresentation(isTruncated: true)
        let rotationText = rotationStringRepresentation()
        let scheduleText = NSMutableAttributedString.init(string: "\(weekdaysText)\n\(rotationText)")
        scheduleText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSMakeRange(0, weekdaysText.count))
        return scheduleText
    }
    
    func setAlarms() {
        for alarm in alarms { alarm.setAlarm(for: self) }
    }
    
}

enum Weekday: Int, CustomStringConvertible, Comparable, Codable {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    
    var description: String {
        switch self {
        case .Sunday: return "Sunday"
        case .Monday: return "Monday"
        case .Tuesday: return "Tuesday"
        case .Wednesday: return "Wednesday"
        case .Thursday: return "Thursday"
        case .Friday: return "Friday"
        case .Saturday: return "Saturday"
        }
    }
    
    func truncated() -> String {
        return String("\(self)".prefix(3))
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum Rotation: Int, CustomStringConvertible, Comparable, Codable {
    case First, Second, Third, Fourth, Fifth
    
    var description: String {
        switch self {
        case .First: return "1st"
        case .Second:  return "2nd"
        case .Third:  return "3rd"
        case .Fourth: return "4th"
        case .Fifth:  return "5th"
        }
    }
    
    static func < (lhs: Rotation, rhs: Rotation) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct Alarm: Codable {
    
    var daysInAdvance: Int
    var hour: Int
    var minute: Int
    
    func generateNextAlarmDay(for schedule: Schedule) -> DateComponents? {
        guard let daysUntilCleaning = schedule.daysUntilCleaning() else { return nil }
        let daysUntilAlarm = daysUntilCleaning - daysInAdvance
        
        let calendar = Calendar(identifier: .gregorian)
        guard let alarmTimeToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) else { return nil }
        guard let alarmDate = calendar.date(byAdding: DateComponents(day: daysUntilAlarm), to: alarmTimeToday) else { return nil }
        let alarmDateComponents = calendar.dateComponents([.calendar, .era, .year, .day, .hour, .minute], from: alarmDate)
        return alarmDateComponents
    }
    
    func stringRepresentation() -> String {
        // can be done with DateFormatter, this allows us to avoid unnecessary complexity though
        let timeString = "\(hour % 12 == 0 ? 12 : hour % 12):\(minute) \(hour >= 12 ? "PM" : "AM")"
        let daysString = "\(daysInAdvance) \(daysInAdvance == 1 ? "day" : "days") before cleaning"
        return "\(timeString), \(daysString)"
    }
    
    func setAlarm(for schedule: Schedule) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            if let error = error {
                print(error)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Move your car!"
        content.body = "You have street cleaning in \(daysInAdvance) day\(daysInAdvance == 1 ? "" : "s")"
        content.sound = UNNotificationSound.default
        
        guard let dateComponents = generateNextAlarmDay(for: schedule) else { return }
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
}
