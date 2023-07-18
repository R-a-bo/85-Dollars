//
//  ScheduleListViewController.swift
//  85 Dollars
//
//  Created by George Birch on 5/31/23.
//

import UIKit

class ScheduleListViewController: UITableViewController {
    
    var schedules = [Schedule]()
    var activeSchedule: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadSchedules()
        
        let userDefaults = UserDefaults.standard
        activeSchedule = userDefaults.object(forKey: "activeSchedule") as? Int ?? -1

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        if schedules.isEmpty { setBackground() }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Schedule", for: indexPath) as? ScheduleListViewCell else {
            fatalError("Unable to dequeue ScheduleListViewCell.")
        }
        
        let schedule = schedules[indexPath.row]
        
        cell.setup(isActive: activeSchedule == indexPath.row, schedule: schedule)
        cell.switchCallback = { [weak self] in
            self?.switchToggled(in: cell)
        }
        cell.optionsButton.menu = UIMenu(children: [
            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.performSegue(withIdentifier: "scheduleDetailPopup", sender: indexPath.row)
            },
            UIAction(title: "Delete Schedule", image: UIImage(systemName: "trash")) { [weak self] _ in
                let scheduleIndex = self?.schedules.firstIndex { $0 === schedule }
                guard let scheduleIndex = scheduleIndex else { return }
                self?.schedules.remove(at: scheduleIndex)
                self?.tableView.deleteRows(at: [IndexPath(row: scheduleIndex, section: 0)], with: .automatic)
                self?.saveSchedules()
                if self?.activeSchedule == scheduleIndex {
                    self?.activeSchedule = -1
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(self?.activeSchedule, forKey: "activeSchedule")
                }
                if self?.tableView.numberOfRows(inSection: 0) == 0 { self?.setBackground() }
            }])

        return cell
    }
    
    // MARK: - Utility methods
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "scheduleDetailPopup", sender: schedules.count)
    }
    
    func switchToggled(in cell: ScheduleListViewCell) {
        tableView.beginUpdates()
        
        guard let indexOfCurrentCell = tableView.indexPath(for: cell)?.row else { return }
        
        if cell.switchButton.isOn {
            if let activeCell = tableView.cellForRow(at: IndexPath(row: activeSchedule, section: 0)) as? ScheduleListViewCell {
                activeCell.setup(isActive: false, schedule: schedules[activeSchedule])
            }
            activeSchedule = indexOfCurrentCell
        } else {
            activeSchedule = -1
        }
        
        cell.setup(isActive: cell.switchButton.isOn, schedule: schedules[indexOfCurrentCell])
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(activeSchedule, forKey: "activeSchedule")
        
        tableView.endUpdates()
    }
    
    func saveSchedules() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in : .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: "Schedules.plist")
            let data = try PropertyListEncoder().encode(schedules)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func loadSchedules() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in : .userDomainMask, appropriateFor: nil, create: true)
                .appending(path: "Schedules.plist")
            let data = try Data(contentsOf: fileURL)
            schedules = try PropertyListDecoder().decode([Schedule].self, from: data)
        } catch {
            print(error)
        }
    }
    
    func setBackground() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height : 50))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .systemGray
        label.text = "Tap '+' to create\nyour first schedule!"
        tableView.backgroundView = label
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? ScheduleDetailViewController, let scheduleIndex = sender as? Int else {
            print("Error passing information to schedule detail view")
            return
        }
        
        if scheduleIndex == schedules.count {
            // new schedule
            schedules.append(Schedule())
            vc.title = "Create cleaning schedule"
            vc.callback = { [weak self] schedule in
                if schedule.weekdays.count > 0 && schedule.weeks.count > 0 {
                    self?.schedules[scheduleIndex] = schedule
                    self?.tableView.insertRows(at: [IndexPath(row: scheduleIndex, section: 0)], with: .bottom)
                    guard let newCell = self?.tableView.cellForRow(at: IndexPath(row: scheduleIndex, section: 0)) as? ScheduleListViewCell else { return }
                    newCell.switchButton.isOn = true
                    self?.switchToggled(in: newCell)
                    self?.saveSchedules()
                    self?.tableView.backgroundView = nil
                } else {
                    self?.schedules.removeLast()
                }
            }
        } else {
            // edit existing schedule
            vc.title = "Edit cleaning schedule"
            vc.callback = { [weak self] schedule in
                if schedule.weekdays.count > 0 && schedule.weeks.count > 0 {
                    self?.schedules[scheduleIndex] = schedule
                    guard let editedCell = self?.tableView.cellForRow(at: IndexPath(row: scheduleIndex, section: 0)) as? ScheduleListViewCell else { return }
                    editedCell.setup(isActive: self?.activeSchedule == scheduleIndex, schedule: schedule)
                    self?.saveSchedules()
                }
            }
        }
        
        vc.schedule = schedules[scheduleIndex]
    }

}
