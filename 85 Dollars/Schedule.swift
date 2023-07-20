//
//  Schedule.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

class Schedule: Codable {
    
    var weekdays = [Weekday]()
    var weeks = [Rotation]()
    var alarms = [Alarm]()
    var hourOfDay: Int?
    var name: String?
    
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
    
}
