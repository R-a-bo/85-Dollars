//
//  Schedule.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

struct Schedule {
    
    var weekdays: [Weekday]
    var weeks: [Rotation]
    var alarms: [TimeInterval]
    var hourOfDay: Int?
    // TODO: make name into a computed property, integrate into UI
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
    
    func weekdaysStringRepresentation() -> String {
        if weekdays.count == 7 {
            return "Every day"
        }
        var result = ""
        for (i, day) in weekdays.enumerated().reversed() {
            if i < weekdays.count - 2 {
                result = "\(day), \(result)"
            } else if i == weekdays.count - 2 {
                result = "\(day) and \(result)"
            } else {
                result = "\(day) \(result)"
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
    
    func alarmStringRepresentation(for alarm: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour]
        let result = formatter.string(from: alarms[alarm])
        if let result = result {
            return "\(result) before cleaning times"
        } else {
            print("Unable to generate string for alarm \(alarm) of \(alarms[alarm])")
            return ""
        }
    }
    
}

enum Weekday: Int, CustomStringConvertible, Comparable {
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
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum Rotation: Int, CustomStringConvertible, Comparable {
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
