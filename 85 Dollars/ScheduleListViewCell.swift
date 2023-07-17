//
//  ScheduleListViewCell.swift
//  85 Dollars
//
//  Created by George Birch on 6/3/23.
//

import UIKit

class ScheduleListViewCell: UITableViewCell, UICalendarViewDelegate {
    
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var countdown: UILabel!
    @IBOutlet var calendarContainerView: UIView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var scheduleLabel: UILabel!
    @IBOutlet var countdownLabel: UILabel!
    
    var calendarView: UICalendarView?
    var schedule: Schedule?
    
    var switchCallback: (() -> Void)?
    
    func setup(isActive: Bool, schedule: Schedule) {
        switchButton.setOn(isActive, animated: true)
        scheduleLabel.isHidden = isActive
        if let daysUntilCleaning = schedule.daysUntilCleaning() {
            countdown.text = String(daysUntilCleaning)
        } else {
            countdown.text = "∞"
        }
        if isActive {
            setupCalendar()
        } else {
            calendarView?.removeFromSuperview()
            scheduleLabel.attributedText = schedule.scheduleTitle()
        }
        scheduleLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupCalendar() {
        calendarView = UICalendarView()
        guard let calendarView = calendarView else { return }
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        
        calendarContainerView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: calendarContainerView.centerXAnchor),
            calendarView.heightAnchor.constraint(equalTo: calendarContainerView.heightAnchor),
        ])
    }

    @IBAction func switchTapped() {
        guard let switchCallback = switchCallback else {
            print("missing switch callback in schedulelisttableviewcell")
            return
        }
        switchCallback()
    }
    
    // MARK: - UICalendarViewDelegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let schedule = schedule else { return nil }
        let cleaningDays = schedule.getCleaningDays(for: dateComponents.month!, of: dateComponents.year!)
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
}
