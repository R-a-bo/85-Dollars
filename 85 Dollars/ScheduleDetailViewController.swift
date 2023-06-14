//
//  ScheduleDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/8/23.
//

import UIKit

class ScheduleDetailViewController: UITableViewController {
    
    var schedule: Schedule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schedule = schedule ?? Schedule(weekdays: [Weekday](), weeks: [Rotation](), alarms: [TimeInterval]())
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        // TODO: test code - delete
        schedule = Schedule(weekdays: [Weekday.Monday, Weekday.Friday], weeks: [Rotation.First, Rotation.Third], alarms: [207360])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Rotation"
        case 1: return "Cleaning days"
        default: return "Alarms"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return schedule.alarms.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0 && schedule.weeks.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "setRotation", for: indexPath)
        } else if indexPath.section == 1 && schedule.weekdays.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "addWeekdays", for: indexPath)
        } else if isAddAlarm(indexPath) {
            cell = tableView.dequeueReusableCell(withIdentifier: "addAlarm", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
            if indexPath.section == 0 {
                setCellText(cell, to: schedule.rotationStringRepresentation())
            } else if indexPath.section == 1 {
                setCellText(cell, to: schedule.weekdaysStringRepresentation())
            } else {
                setCellText(cell, to: schedule.alarmStringRepresentation(for: indexPath.row))
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAddAlarm(indexPath) {
            openTimeSelector(isExistingAlarm: false)
        } else if indexPath.section == 2 {
            openTimeSelector(isExistingAlarm: true)
        } else if isAddWeekday(indexPath) {
            openWeekdaySelector(selectedWeekday: nil)
        } 
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    // MARK: - Utility functions
    
    // determines if the tableviewcell at the given indexpath is the "add weekday" button
    func isAddWeekday(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
    
    // determines if the tableviewcell at the given indexpath is the "add alarm" button
    func isAddAlarm(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
    
    func openTimeSelector(isExistingAlarm: Bool) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AlarmDetail") as? AlarmDetailViewController {
            if isExistingAlarm {
                vc.title = "Edit alarm"
            } else {
                vc.title = "Create alarm"
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setCellText(_ cell: UITableViewCell, to text: String) {
        var content = cell.defaultContentConfiguration()
        content.text = text
        cell.contentConfiguration = content
    }
    
    // selectedWeekday is the chosen weekday if this is being called to edit a weekday item
    func openWeekdaySelector(selectedWeekday: Int?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WeekdayDetail") as? WeekdayDetailViewController {
            if let selectedWeekday = selectedWeekday {
                //TODO: pass down to VC
            } else {
                //TODO: dont pass down to vc
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
