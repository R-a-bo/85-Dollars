//
//  ScheduleListViewController.swift
//  85 Dollars
//
//  Created by George Birch on 5/31/23.
//

import UIKit

class ScheduleListViewController: UITableViewController, UICalendarViewDelegate {
    
    var calendarView: UICalendarView!
    
    var schedules = [Schedule]()
    var activeSchedule: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSchedules()
        
        let userDefaults = UserDefaults.standard
        activeSchedule = userDefaults.object(forKey: "activeSchedule") as? Int ?? -1

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
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
        cell.switchButton.isOn = activeSchedule == indexPath.row
        cell.switchCallback = { [weak self] in
            self?.switchToggled(in: cell)
        }
        
        if let daysUntilCleaning = schedule.daysUntilCleaning() {
            cell.countdown.text = String(daysUntilCleaning)
        } else {
            cell.countdown.text = "∞"
        }
        
        if activeSchedule == indexPath.row {
            cell.scheduleLabel.isHidden = true
            setupCalendar(for: cell)
            setAlarms(for: schedule)
        }
        
        cell.scheduleLabel.adjustsFontSizeToFitWidth = true
        cell.countdownLabel.adjustsFontSizeToFitWidth = true
        
        cell.optionsButton.menu = UIMenu(children: [
            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.performSegue(withIdentifier: "scheduleDetailPopup", sender: indexPath.row)
            },
            UIAction(title: "Delete Schedule", image: UIImage(systemName: "trash")) { [weak self] _ in
                self?.schedules.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.saveSchedules()
                if self?.activeSchedule == indexPath.row {
                    self?.activeSchedule = -1
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(self?.activeSchedule, forKey: "activeSchedule")
                }
                if self?.tableView.numberOfRows(inSection: 0) == 0 { self?.setBackground() }
            }])
        
        cell.scheduleLabel.attributedText = schedules[indexPath.row].scheduleTitle()

        return cell
    }
    
    // MARK: - Utility methods
    
    func setupCalendar(for cell: ScheduleListViewCell) {
        cell.calendarContainerView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: cell.calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: cell.calendarContainerView.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: cell.calendarContainerView.centerXAnchor),
            calendarView.heightAnchor.constraint(equalTo: cell.calendarContainerView.heightAnchor),
        ])
    }
    
    func refreshCalendar() {
        let calendar = Calendar(identifier: .gregorian)
        let thisMonthComponents = calendar.dateComponents([.month, .year], from: Date())
        var currentMonthDates = [DateComponents]()
        for i in 1...31 {
            currentMonthDates.append(DateComponents(calendar: calendar, era: 1, year: thisMonthComponents.year!, month: thisMonthComponents.month!, day: i))
        }
        calendarView.reloadDecorations(forDateComponents: currentMonthDates, animated: true)
    }
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "scheduleDetailPopup", sender: schedules.count)
    }
    
    func switchToggled(in cell: ScheduleListViewCell) {
        tableView.beginUpdates()
        calendarView.removeFromSuperview()
        if cell.switchButton.isOn {
            cell.scheduleLabel.isHidden = true
            setupCalendar(for: cell)
            
            if let activeCell = tableView.cellForRow(at: IndexPath(row: activeSchedule, section: 0)) as? ScheduleListViewCell {
                activeCell.switchButton.setOn(false, animated: true)
                activeCell.scheduleLabel.isHidden = false
                refreshCellTitle(activeCell)
            }
            
            guard let indexOfCurrentCell = tableView.indexPath(for: cell) else { return }
            
            activeSchedule = indexOfCurrentCell.row
            
            refreshCalendar()
            
            setAlarms(for: schedules[activeSchedule])
        } else {
            cell.scheduleLabel.isHidden = false
            refreshCellTitle(cell)
            activeSchedule = -1
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(activeSchedule, forKey: "activeSchedule")
        
        tableView.endUpdates()
    }
    
    func refreshCellTitle(_ cell: ScheduleListViewCell) {
        guard let scheduleIndex = tableView.indexPath(for: cell)?.row else { return }
        cell.scheduleLabel.attributedText = schedules[scheduleIndex].scheduleTitle()
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
    
    func setAlarms(for schedule: Schedule) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        schedule.setAlarms()
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
    
    // MARK: - UICalendarViewDelegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let cleaningDays = schedules[activeSchedule].getCleaningDays(for: dateComponents.month!, of: dateComponents.year!)
        if cleaningDays.contains(dateComponents) {
            return .customView {
                let cleaningEmoji = UILabel()
                cleaningEmoji.text = "🧹"
                return cleaningEmoji
            }
        } else {
            return nil
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? ScheduleDetailViewController, let scheduleIndex = sender as? Int else {
            print("Error passing information to schedule detail view")
            return
        }
        
        if scheduleIndex == schedules.count {
            // new schedule
            schedules.append(Schedule(weekdays: [Weekday](), weeks: [Rotation](), alarms: [Alarm]()))
            vc.title = "Create cleaning schedule"
            vc.callback = { [weak self] schedule in
                if schedule.weekdays.count > 0 && schedule.weeks.count > 0 {
                    self?.schedules[scheduleIndex] = schedule
                    self?.tableView.insertRows(at: [IndexPath(row: scheduleIndex, section: 0)], with: .bottom)
                    guard let newCell = self?.tableView.cellForRow(at: IndexPath(row: scheduleIndex, section: 0)) as? ScheduleListViewCell else { return }
                    newCell.switchButton.setOn(true, animated: true)
                    self?.setAlarms(for: schedule)
                    self?.switchToggled(in: newCell)
                    self?.saveSchedules()
                    self?.tableView.backgroundView = nil
                }
            }
        } else {
            // edit existing schedule
            vc.title = "Edit cleaning schedule"
            vc.callback = { [weak self] schedule in
                if schedule.weekdays.count > 0 && schedule.weeks.count > 0 {
                    self?.schedules[scheduleIndex] = schedule
                    if self?.activeSchedule == scheduleIndex { self?.refreshCalendar() }
                    guard let editedCell = self?.tableView.cellForRow(at: IndexPath(row: scheduleIndex, section: 0)) as? ScheduleListViewCell else { return }
                    self?.refreshCellTitle(editedCell)
                    self?.saveSchedules()
                }
            }
        }
        
        vc.schedule = schedules[scheduleIndex]
    }

}
