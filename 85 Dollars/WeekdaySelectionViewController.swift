//
//  WeekdaySelectionViewController.swift
//  85 Dollars
//
//  Created by George Birch on 7/25/23.
//

import UIKit

class WeekdaySelectionViewController: PatternSelectionViewController {
    
    func loadWeekdays(_ rotation: [Weekday]) {
        for _ in 0..<7 {
            selection.append(false)
        }
        for r in rotation {
            selection[r.rawValue - 1] = true
        }
        tableView.reloadData()
    }
    
    override func cellTitle(for index: Int) -> String {
        if index == 7 {
            return "Every day"
        } else {
            guard let day = Weekday(rawValue: index + 1) else { return "" }
            return String(describing: day)
        }
    }
    
}
