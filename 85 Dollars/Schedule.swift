//
//  Schedule.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

struct Schedule {
    
    var weekdays: Set<Weekday>
    var weeks: Set<Rotation>
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
    
}

enum Weekday: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

enum Rotation: Int {
    case first, second, third, fourth, fifth
}
