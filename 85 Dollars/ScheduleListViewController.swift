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
    var activeSchedule = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
        // TODO: test code
        schedules.append(Schedule(weekdays: [Weekday.Monday, Weekday.Friday], weeks: [Rotation.First, Rotation.Third], alarms: [TimeInterval]()))
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
            cell.scheduleText.isHidden = true
            setupCalendar(for: cell)
        }
        
        cell.optionsButton.menu = UIMenu(children: [
            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.performSegue(withIdentifier: "scheduleDetailPopup", sender: indexPath.row)
            },
            UIAction(title: "Delete Schedule", image: UIImage(systemName: "trash")) { [weak self] _ in
                self?.schedules.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }])

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
            cell.scheduleText.isHidden = true
            setupCalendar(for: cell)
            
            let activeCell = tableView.cellForRow(at: IndexPath(row: activeSchedule, section: 0))
            guard let activeCell = activeCell as? ScheduleListViewCell else { return }
            activeCell.switchButton.setOn(false, animated: true)
            activeCell.scheduleText.isHidden = false
            
            guard let indexOfCurrentCell = tableView.indexPath(for: cell) else { return }
            
            activeSchedule = indexOfCurrentCell.row
            refreshCalendar()
        } else {
            cell.scheduleText.isHidden = false
        }
        tableView.endUpdates()
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
            schedules.append(Schedule(weekdays: [Weekday](), weeks: [Rotation](), alarms: [TimeInterval]()))
            vc.title = "Create cleaning schedule"
        } else {
            // edit existing schedule
            vc.title = "Edit cleaning schedule"
        }
        
        vc.schedule = schedules[scheduleIndex]
        vc.callback = { [weak self] schedule in
            self?.schedules[scheduleIndex] = schedule
            self?.tableView.insertRows(at: [IndexPath(row: scheduleIndex, section: 0)], with: .bottom)
            guard let newCell = self?.tableView.cellForRow(at: IndexPath(row: scheduleIndex, section: 0)) as? ScheduleListViewCell else { return }
            newCell.switchButton.setOn(true, animated: true)
            self?.switchToggled(in: newCell)
        }
    }

}
