//
//  RotationPickerViewModel.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import OSLog
import SwiftUI

// TODO: make this work as a protocol, or otherwise don't subclass this
class RotationSelectionViewModel: ObservableObject {
    
    @Published var elements: [RotationSelectionElement]
    
    init(elements: [RotationSelectionElement]) {
        self.elements = elements
    }
    
    func didTapElement(_ id: Int) {
        elements[id].isSelected.toggle()
    }
}

class WeekdaySelectionViewModel: RotationSelectionViewModel {
    
    private static let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WeekdaySelectionViewModel")
    
    // New schedule
    init() {
        let elements = Self.daysOfWeek.enumerated().map {
            RotationSelectionElement(id: $0.0, text: $0.1, isSelected: false)
        }
        super.init(elements: elements)
    }
        
    // Existing schedule
    init(selectedWeekdays: Set<Weekday>) {
        let elements: [RotationSelectionElement] = Self.daysOfWeek.enumerated().compactMap {
            guard let correspondingWeekday = Weekday(rawValue: $0.0) else {
                Self.logger.error("Invalid weekday value of \($0.0)")
                return nil
            }
            return RotationSelectionElement(
                id: $0.0,
                text: $0.1,
                isSelected: selectedWeekdays.contains(correspondingWeekday)
            )
        }
        super.init(elements: elements)
    }
}

class MonthweekSelectionViewModel: RotationSelectionViewModel {
    
    private static let weeksOfMonth = ["1st", "2nd", "3rd", "4th", "5th", "All"]
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MonthweekSelectionViewModel")
    
    // New schedule
    init() {
        let elements = Self.weeksOfMonth.enumerated().map {
            RotationSelectionElement(id: $0.0, text: $0.1, isSelected: false)
        }
        super.init(elements: elements)
    }
    
    // Existing schedule
    init(selectedWeeks: Set<Monthweek>) {
        let elements: [RotationSelectionElement] = Self.weeksOfMonth.enumerated().compactMap {
            // special behavior for "All" button
            if $0.0 == 5 {
                let allOn = selectedWeeks.count == 5
                return RotationSelectionElement(id: $0.0, text: $0.1, isSelected: allOn)
            }
            guard let correspondingWeek = Monthweek(rawValue: $0.0) else {
                Self.logger.error("Invalid week value of \($0.0)")
                return nil
            }
            return RotationSelectionElement(
                id: $0.0,
                text: $0.1,
                isSelected: selectedWeeks.contains(correspondingWeek)
            )
        }
        super.init(elements: elements)
    }
    
    override func didTapElement(_ id: Int) {
        switch (id, elements[id].isSelected) {
        // handle "All" tapped, was previously off
        case (5, false):
            // turn everything on
            elements = elements.map {
                var element = $0
                element.isSelected = true
                return element
            }
        // handle "All" tapped, was previously on
        case (5, true):
            // turn everything off
            elements = elements.map {
                var element = $0
                element.isSelected = false
                return element
            }
        // handle something else being turned on
        case (_, false):
            let allElseOn = elements.allSatisfy {
                $0.id == 5 // pass the "All" button
                || $0.id == id // pass the current button
                || $0.isSelected // is on
            }
            // if so, turn "All" button on
            if allElseOn {
                elements[5].isSelected = true
            }
            elements[id].isSelected = true
        // handle something else being turned off
        case (_, true):
            // turn off "All" button
            elements[5].isSelected = false
            elements[id].isSelected = false
        }
    }
}
