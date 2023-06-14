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
        if let daysUntilCleaning = schedule.daysUntilCleaning() {
            cell.countdown.text = String(daysUntilCleaning)
        } else {
            cell.countdown.text = "∞"
        }
        
        if activeSchedule == indexPath.row {
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
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "scheduleDetailPopup", sender: navigationItem.rightBarButtonItem)
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
        guard let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? ScheduleDetailViewController else {
            print("Error passing information to schedule detail view")
            return
        }
        // check if we're editing an existing schedule
        if let senderIndex = sender as? Int {
            vc.schedule = schedules[senderIndex]
            vc.callback = { [weak self] schedule in
                self?.schedules[senderIndex] = schedule
                self?.tableView.reloadData()
                
                // reload calendarview
                let calendar = Calendar(identifier: .gregorian)
                let thisMonthComponents = calendar.dateComponents([.month, .year], from: Date())
                var currentMonthDates = [DateComponents]()
                for i in 1...31 {
                    currentMonthDates.append(DateComponents(calendar: calendar, era: 1, year: thisMonthComponents.year!, month: thisMonthComponents.month!, day: i))
                }
                self?.calendarView.reloadDecorations(forDateComponents: currentMonthDates, animated: true)
            }
            vc.title = "Edit cleaning schedule"
        } else {
            vc.title = "Create cleaning schedule"
        }
    }

}
