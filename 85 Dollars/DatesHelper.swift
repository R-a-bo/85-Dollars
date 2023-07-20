//
//  ScheduleHelper.swift
//  85 Dollars
//
//  Created by George Birch on 7/19/23.
//

import UIKit

class DatesHelper {
    
    static func daysUntilCleaning(for schedule: Schedule) -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        let todayComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        guard let currentMonth = todayComponents.month, let currentYear = todayComponents.year else { return 0 }
        
        if let shortestDaysUntilCleaning = daysUntilCleaning(for: schedule, from: todayComponents, to: currentMonth, of: currentYear, accordingTo: calendar) {
            return shortestDaysUntilCleaning
        }
        
        let nextMonth = currentMonth == 12 ? 1 : currentMonth + 1
        let nextMonthYear = currentMonth == 12 ? currentYear + 1 : currentYear
        return daysUntilCleaning(for: schedule, from: todayComponents, to: nextMonth, of: nextMonthYear, accordingTo: calendar)
    }
    
    private static func daysUntilCleaning(for schedule: Schedule, from todayComponents: DateComponents, to month: Int, of year: Int, accordingTo calendar: Calendar) -> Int? {
        let currentMonthCleaningDays = getCleaningDays(for: schedule, in: month, of: year)
        let timesUntilCleaning = currentMonthCleaningDays.map { (components) -> Int in
            let dateDifference = calendar.dateComponents([.day], from: todayComponents, to: components)
            return dateDifference.day ?? 0
        }.filter { $0 > 0 }
        return timesUntilCleaning.min()
    }
    
    // returns set of street cleaning days as DateComponents's for the given month
    static func getCleaningDays(for schedule: Schedule, in month: Int, of year: Int) -> Set<DateComponents> {
        let calendar = Calendar(identifier: .gregorian)
        let currentMonth = calendar.dateComponents([.year, .month], from: Date())
        let monthsFromNowComponents = calendar.dateComponents([.month], from: DateComponents(year: currentMonth.year!, month: currentMonth.month!), to: DateComponents(year: year, month: month))
        
        guard let monthsFromNow = monthsFromNowComponents.month else { return Set<DateComponents>() }
        
        var dates = Set<DateComponents>()
        
        var firstOfMonthComponents = DateComponents(year: year, month: month, day: 1)
        let firstOfMonthDate = calendar.date(from: firstOfMonthComponents)
        guard let firstOfMonthDate = firstOfMonthDate else { return dates }
        firstOfMonthComponents = calendar.dateComponents([.weekday], from: firstOfMonthDate)
        guard let weekdayOfFirst = firstOfMonthComponents.weekday else { return dates }
        
        for weekday in schedule.weekdays {
            let daysUntilWeekday = weekday.rawValue - weekdayOfFirst
            let nearbyWeekday = 1 + daysUntilWeekday
            var firstWeekdayOfMonth = (nearbyWeekday + 7) % 7
            firstWeekdayOfMonth = firstWeekdayOfMonth == 0 ? 7 : firstWeekdayOfMonth
            for week in schedule.weeks {
                let cleaningDay = DateComponents(calendar: calendar, era: 1, year: year, month: month, day: firstWeekdayOfMonth + week.rawValue * 7)
                dates.insert(cleaningDay)
            }
        }
        
        return dates
    }
    
    static func generateNextAlarmDay(for alarm: Alarm, in schedule: Schedule) -> DateComponents? {
        guard let daysUntilCleaning = daysUntilCleaning(for: schedule) else { return nil }
        let daysUntilAlarm = daysUntilCleaning - alarm.daysInAdvance
        
        let calendar = Calendar(identifier: .gregorian)
        guard let alarmTimeToday = calendar.date(bySettingHour: alarm.hour, minute: alarm.minute, second: 0, of: Date()) else { return nil }
        guard let alarmDate = calendar.date(byAdding: DateComponents(day: daysUntilAlarm), to: alarmTimeToday) else { return nil }
        let alarmDateComponents = calendar.dateComponents([.calendar, .era, .year, .day, .hour, .minute], from: alarmDate)
        return alarmDateComponents
    }
    
    static func setAlarms(for schedule: Schedule) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for alarm in schedule.alarms {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
                if let error = error {
                    print(error)
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Move your car!"
            content.body = "You have street cleaning in \(alarm.daysInAdvance) day\(alarm.daysInAdvance == 1 ? "" : "s")"
            content.sound = UNNotificationSound.default
            
            guard let dateComponents = generateNextAlarmDay(for: alarm, in: schedule) else { return }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
}
