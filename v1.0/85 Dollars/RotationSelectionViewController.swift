//
//  RotationSelectionViewController.swift
//  85 Dollars
//
//  Created by George Birch on 7/25/23.
//

import UIKit

class RotationSelectionViewController: PatternSelectionViewController {
    
    func loadRotation(_ rotation: [Rotation]) {
        for _ in 0..<4 {
            selection.append(false)
        }
        for r in rotation {
            if r.rawValue < 4 {
                selection[r.rawValue] = true
            }
        }
        tableView.reloadData()
    }
    
    override func cellTitle(for index: Int) -> String {
        if index == 4 {
            return "Every week"
        } else {
            guard let week = Rotation(rawValue: index) else { return "" }
            return String(describing: week)
        }
    }
    
}
