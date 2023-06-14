//
//  RotationDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/13/23.
//

import UIKit

class RotationDetailViewController: UITableViewController {
    
    var weeks: [Rotation]!
    var callback: ((_: [Rotation]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        if weeks == nil {
            weeks = [Rotation]()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let callback = callback {
            callback(weeks)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rotation", for: indexPath)

        var content = cell.defaultContentConfiguration()
        if indexPath.row == 4 {
            content.text = "Every week"
            if weeks.count == 5 {
                cell.accessoryType = .checkmark
            }
        } else {
            content.text = "\(Rotation(rawValue: indexPath.row)!)"
        }
        cell.contentConfiguration = content
        if let weeks = weeks, let week = Rotation(rawValue: indexPath.row), weeks.contains(week) {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            weeks.removeAll() { week in
                return week.rawValue == indexPath.row
            }
            let finalCell = tableView.cellForRow(at: IndexPath(row: 4, section: indexPath.section))
            finalCell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
            if indexPath.row == 4 {
                for i in 0...3 {
                    let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))
                    otherCell?.accessoryType = .checkmark
                    addWeek(i)
                }
            } else {
                addWeek(indexPath.row)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - utility functions
    
    func addWeek(_ i: Int) {
        guard let week = Rotation(rawValue: i) else {
            print("Error updating rotation list tableview")
            return
        }
        if !weeks.contains(week) {
            weeks.append(week)
            weeks.sort()
        }
    }
    
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}
