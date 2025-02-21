//
//  ScheduleRepository.swift
//  85Dollars
//
//  Created by George Birch on 2/15/25.
//

import Foundation
import OSLog

protocol ScheduleRepository {
    func saveSchedule(_ schedule: Schedule) throws
    func deleteSchedule(id: UUID) throws
    func getSchedules() throws -> [Schedule]
}

class DiskScheduleRepository: ScheduleRepository {
    
    private static let fileUrl = URL.documentsDirectory.appending(path: "schedules.json")
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DiskScheduleRepository")
    
    init() throws {
        // ensure that file exists
        if !FileManager.default.fileExists(atPath: "schedules.json") {
            logger.info("No schedules file found, creating")
            let emptySchedules = [Schedule]()
            let data = try JSONEncoder().encode(emptySchedules)
            try data.write(to: Self.fileUrl)
        }
    }
    
    func saveSchedule(_ schedule: Schedule) throws {
        var schedules = try getSchedules()
        if let i = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[i] = schedule
        } else {
            schedules.append(schedule)
        }
        let data = try JSONEncoder().encode(schedules)
        try data.write(to: Self.fileUrl)
    }
    
    func deleteSchedule(id: UUID) throws {
        var schedules = try getSchedules()
        guard let i = schedules.firstIndex(where: { $0.id == id} ) else {
            throw RepositoryError.scheduleNotFound
        }
        schedules.remove(at: i)
        let data = try JSONEncoder().encode(schedules)
        try data.write(to: Self.fileUrl)
    }
    
    func getSchedules() throws -> [Schedule] {
        let data = try Data(contentsOf: Self.fileUrl)
        return try JSONDecoder().decode([Schedule].self, from: data)
    }
}
