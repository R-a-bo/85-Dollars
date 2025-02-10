//
//  ScheduleDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/8/23.
//

import UIKit

class ScheduleDetailViewController: UITableViewController {
    
    var schedule: Schedule!
    var callback: ((_: Schedule) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schedule = schedule ?? Schedule()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
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
                setCellText(cell, to: StringHelper.string(for: schedule.weeks))
            } else if indexPath.section == 1 {
                setCellText(cell, to: StringHelper.string(for: schedule.weekdays, isTruncated: false))
            } else {
                setCellText(cell, to: StringHelper.string(for: schedule.alarms[indexPath.row]))
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            openRotationSelector()
        } else if indexPath.section == 1 {
            openWeekdaySelector()
        } else if isAddAlarm(indexPath) {
            openTimeSelector(forAlarmAt: tableView.numberOfRows(inSection: 2))
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == 2 {
            openTimeSelector(forAlarmAt: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && indexPath.row != schedule.alarms.count {
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            schedule.alarms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Utility functions
    
    // determines if the tableviewcell at the given indexpath is the "add alarm" button
    func isAddAlarm(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
    
    func openRotationSelector() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "RotationSelector") as? RotationSelectionViewController {
            vc.loadRotation(schedule.weeks)
            vc.callback = { [weak self] returnedSelection in
                var weeks = [Rotation]()
                var allSelected = true
                for i in 0..<returnedSelection.count {
                    if returnedSelection[i] {
                        guard let week = Rotation(rawValue: i) else { return }
                        weeks.append(week)
                    } else {
                        allSelected = false
                    }
                }
                if allSelected {
                    weeks.append(Rotation.Fifth)
                }
                self?.schedule.weeks = weeks
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openWeekdaySelector() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WeekdaySelector") as? WeekdaySelectionViewController {
            vc.loadWeekdays(schedule.weekdays)
            vc.callback = { [weak self] returnedSelection in
                var days = [Weekday]()
                for i in 0..<returnedSelection.count {
                    if returnedSelection[i] {
                        guard let day = Weekday(rawValue: i + 1) else { return }
                        days.append(day)
                    }
                }
                self?.schedule.weekdays = days
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openTimeSelector(forAlarmAt index: Int) {
        if index < tableView.numberOfRows(inSection: 2), let vc = storyboard?.instantiateViewController(withIdentifier: "AlarmDetail") as? AlarmDetailViewController {
            vc.title = "Edit alarm"
            vc.callback = { [weak self] returnedAlarm in
                if let returnedAlarm = returnedAlarm {
                    self?.schedule.alarms[index] = returnedAlarm
                } else {
                    self?.schedule.alarms.remove(at: index)
                }
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            performSegue(withIdentifier: "newAlarmPopup", sender: nil)
        }
    }
    
    func setCellText(_ cell: UITableViewCell, to text: String) {
        var content = cell.defaultContentConfiguration()
        content.text = text
        cell.contentConfiguration = content
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? AlarmDetailViewController, segue.identifier == "newAlarmPopup" {
            vc.callback = { [weak self] returnedAlarm in
                if let returnedAlarm = returnedAlarm {
                    self?.schedule.alarms.append(returnedAlarm)
                    self?.tableView.reloadData()
                }
            }
            vc.isPopup = true
        }
    }
    
    @objc func doneButtonTapped() {
        if schedule.weeks.count == 0 || schedule.weekdays.count == 0 {
            var message: String?
            if schedule.weeks.count == 0 && schedule.weekdays.count > 0 {
                message = "Please add a monthly rotation to your schedule"
            } else if schedule.weeks.count > 0 {
                message = "Please add weekdays to your schedule"
            } else {
                message = "Please add a monthly rotation and weekdays to your schedule"
            }
            let ac = UIAlertController(title: "Empty schedule", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        else {
            if let callback = callback {
                callback(schedule)
            } else {
                print("Missing callback for schedule list")
            }
            dismiss(animated: true)
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }

}
