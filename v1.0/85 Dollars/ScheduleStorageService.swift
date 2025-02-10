//
//  ScheduleStorageService.swift
//  85 Dollars
//
//  Created by George Birch on 7/25/23.
//

import Foundation

protocol ScheduleStorageService {
    
    func saveActiveSchedule(index: Int?)
    func loadActiveSchedule() -> Int
    
    func saveSchedules(schedules: [Schedule]?)
    func loadSchedules() -> [Schedule]
    
}

class ScheduleFileService: ScheduleStorageService {
    
    func saveActiveSchedule(index: Int?) {
        UserDefaults.standard.set(index, forKey: "activeSchedule")
    }
    
    func loadActiveSchedule() -> Int {
        return UserDefaults.standard.object(forKey: "activeSchedule") as? Int ?? -1
    }
    
    func saveSchedules(schedules: [Schedule]?) {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in : .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: "Schedules.plist")
            let data = try PropertyListEncoder().encode(schedules)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func loadSchedules() -> [Schedule] {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in : .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: "Schedules.plist")
            let data = try Data(contentsOf: fileURL)
            return try PropertyListDecoder().decode([Schedule].self, from: data)
        } catch {
            print(error)
            return [Schedule]()
        }
    }
    
}

class MockScheduleStorageService: ScheduleStorageService {
    
    func saveActiveSchedule(index: Int?) {}
    
    func loadActiveSchedule() -> Int {
        return 0
    }
    
    func saveSchedules(schedules: [Schedule]?) {}
    
    func loadSchedules() -> [Schedule] {
        return [Schedule(weekdays: [Weekday.Friday], weeks: [Rotation.First], alarms: [Alarm(daysInAdvance: 2, hour: 5, minute: 30)])]
    }
    
}
