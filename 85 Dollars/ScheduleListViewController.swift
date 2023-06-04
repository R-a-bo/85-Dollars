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

        // TODO: set up editing
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
        // TODO: test code
        schedules.append(Schedule(weekdays: [Weekday.monday], weeks: [Rotation.first, Rotation.second, Rotation.third, Rotation.fourth], name: "test"))
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
        cell.countdown.text = String(schedule.daysUntilCleaning())
        
        if activeSchedule == indexPath.row {
            setupCalendar(for: cell)
        }

        return cell
    }

    /*
    // Override to support editing the table view.
    // TODO: set up editing
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
     // TODO:
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
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
    
    // MARK: - UICalendarViewDelegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let cleaningDays = schedules[activeSchedule].streetCleaningDays()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
