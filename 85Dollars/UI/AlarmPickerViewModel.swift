//
//  AlarmPickerViewModel.swift
//  85Dollars
//
//  Created by George Birch on 2/11/25.
//

import OSLog
import SwiftUI

class AlarmPickerViewModel: ObservableObject, Identifiable {
    
    @Published var dayOptions = [
        "Day of cleaning",
        "1 day before cleaning",
        "2 days before cleaning",
        "3 days before cleaning",
        "4 days before cleaning",
        "5 days before cleaning",
        "6 days before cleaning",
        "1 week before cleaning",
    ]
    @Published var selectedDay: Int
    @Published var time: Date
    @Published var id: UUID
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AlarmPickerViewModel")
    
    // VM for existing alarm
    init(alarm: Alarm) throws {
        self.selectedDay = alarm.daysBeforeCleaning
        guard let hour = alarm.time.hour, let minute = alarm.time.minute else {
            logger.error("Missing hour or minute in alarm data")
            throw UIError.invalidData
        }
        guard let date =  Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date.now) else {
            logger.error("Invalid alarm time date - unable to construct Date object")
            throw UIError.invalidData
        }
        self.time = date
        self.id = alarm.id
    }
    
    // VM for new alarm
    init() {
        self.selectedDay = 0
        self.time = Date()
        self.id = UUID()
    }
    
    func toAlarm() -> Alarm {
        Alarm(time: Calendar.current.dateComponents([.hour, .minute], from: time),
                     daysBeforeCleaning: selectedDay,
                     id: id)
    }
}
