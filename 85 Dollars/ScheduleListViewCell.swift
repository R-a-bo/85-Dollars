//
//  ScheduleListViewCell.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

class ScheduleListViewCell: UITableViewCell {
    
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var countdown: UILabel!
    @IBOutlet var calendarContainerView: UIView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var scheduleLabel: UILabel!
    
    var switchCallback: (() -> Void)?

    @IBAction func switchTapped() {
        guard let switchCallback = switchCallback else {
            print("missing switch callback in schedulelisttableviewcell")
            return
        }
        switchCallback()
    }
}
