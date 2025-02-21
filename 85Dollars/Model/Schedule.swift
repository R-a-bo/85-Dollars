//
//  Schedule.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import Foundation

// MARK: - supporting types

enum Weekday: Int, Codable {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

enum Monthweek: Int, Codable {
    case first = 0
    case second
    case third
    case fourth
    case fifth
}

struct Alarm: Codable {
    var time: DateComponents
    var daysBeforeCleaning: Int
    var id: UUID
}

// MARK: - Schedule

// TODO: add support for hour of day
struct Schedule: Codable {
    let id: UUID
    var weekdays: [Weekday]
    var monthweeks: [Monthweek]
    var alarms: [Alarm]
}
