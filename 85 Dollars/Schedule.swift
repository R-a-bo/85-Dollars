//
//  Schedule.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

struct Schedule {
    
    var isActive: Bool
    var weekdays: Set<Weekday>
    var weeks: Set<Rotation>
    // TODO: make name into a computed property
    var name: String
    
    func daysUntilCleaning() -> Int {
        // TODO: fill in method
        return 0
    }

}

enum Weekday {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

enum Rotation {
    case first, second, third, fourth
}