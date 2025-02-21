//
//  ScheduleRepositoryStub.swift
//  85Dollars
//
//  Created by George Birch on 2/16/25.
//

import Foundation

class ScheduleRepositoryStub: ScheduleRepository {
    
    func saveSchedule(_ schedule: Schedule) throws {
        // no op
    }
    
    func deleteSchedule(id: UUID) throws {
        // no op
    }
    
    func getSchedules() throws -> [Schedule] {
        return []
    }
}
