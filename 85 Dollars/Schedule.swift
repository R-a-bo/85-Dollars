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
    // TODO: make name into a computed property
    var name: String?
    
    func daysUntilCleaning() -> Int {
        // TODO: fill in method
        return 0
    }
    
    // TODO: refactor so that cleaning days are stored in class and don't need to be generated over and over
    func streetCleaningDays(forMonthIncluding dateComponents: DateComponents) -> Set<DateComponents> {
        var dates = Set<DateComponents>()
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dateComponents)
        guard let date = date else { return dates }
        let currentWeekday = calendar.component(.weekday, from: date)
        
        for weekday in weekdays {
            let daysUntilWeekday = weekday.rawValue - currentWeekday
            let nearbyWeekday = dateComponents.day! + daysUntilWeekday
            var firstWeekdayOfMonth = (nearbyWeekday + 7) % 7
            if firstWeekdayOfMonth == 0 {
                firstWeekdayOfMonth = 7
            }
            for week in weeks {
                let cleaningDay = DateComponents(calendar: calendar, era: 1, year: dateComponents.year!, month: dateComponents.month!, day: firstWeekdayOfMonth + week.rawValue * 7)
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
