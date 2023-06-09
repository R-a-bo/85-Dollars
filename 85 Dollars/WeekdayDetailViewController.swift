//
//  WeekdayDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/13/23.
//

import UIKit

class WeekdayDetailViewController: UITableViewController {
    
    var weekdays: [Weekday]!
    var callback: ((_: [Weekday]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        if weekdays == nil {
            weekdays = [Weekday]()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let callback = callback {
            callback(weekdays)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekday", for: indexPath)

        var content = cell.defaultContentConfiguration()
        if indexPath.row == 7 {
            content.text = "Every day"
            if weekdays.count == 7 {
                cell.accessoryType = .checkmark
            }
        } else {
            content.text = "\(Weekday(rawValue: indexPath.row + 1)!)"
        }
        cell.contentConfiguration = content
        if let weekdays = weekdays, let day = Weekday(rawValue: indexPath.row + 1), weekdays.contains(day) {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            weekdays.removeAll() { day in
                return day.rawValue - 1 == indexPath.row
            }
            let finalCell = tableView.cellForRow(at: IndexPath(row: 7, section: indexPath.section))
            finalCell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
            if indexPath.row == 7 {
                for i in 0...6 {
                    let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))
                    otherCell?.accessoryType = .checkmark
                    addWeekday(i + 1)
                }
            } else {
                addWeekday(indexPath.row + 1)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - utility functions
    
    func addWeekday(_ i: Int) {
        guard let day = Weekday(rawValue: i) else {
            print("Error updating weekday list tableview")
            return
        }
        if !weekdays.contains(day) {
            weekdays.append(day)
            weekdays.sort()
        }
    }
    
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}
