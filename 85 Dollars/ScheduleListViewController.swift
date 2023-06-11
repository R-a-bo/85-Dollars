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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: give data when editing schedule
    }

}
