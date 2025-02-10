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
    
    var calendarView = UICalendarView()
    var cleaningDays = NSCache<NSNumber, DateSet>()
    var schedule: Schedule?
    var switchCallback: (() -> Void)?
    
    func setup(isActive: Bool, schedule: Schedule) {
        self.schedule = schedule
        switchButton.setOn(isActive, animated: true)
        scheduleLabel.isHidden = isActive
        setupCountdownLabel(schedule: schedule)
        if isActive {
            setupCalendar()
            DatesHelper.setAlarms(for: schedule)
        } else {
            calendarView.removeFromSuperview()
            scheduleLabel.attributedText = StringHelper.string(for: schedule)
        }
        scheduleLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupCountdownLabel(schedule: Schedule) {
        if let daysUntilCleaning = DatesHelper.daysUntilCleaning(for: schedule) {
            countdown.text = String(daysUntilCleaning)
        } else {
            countdown.text = "∞"
        }
    }
    
    func setupCalendar() {
        cleaningDays = NSCache<NSNumber, DateSet>()
        
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
        let monthsKey = dateComponents.month! + dateComponents.year! * 12 as NSNumber
        if cleaningDays.object(forKey: monthsKey) == nil {
            let days = DatesHelper.getCleaningDays(for: schedule, in: dateComponents.month!, of: dateComponents.year!)
            cleaningDays.setObject(DateSet(days), forKey: monthsKey)
        }
        if cleaningDays.object(forKey: monthsKey)!.dates.contains(dateComponents) {
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

// class wrapper for Set<DateComponents> to let it play nicely with NSCache
class DateSet {
    
    let dates: Set<DateComponents>
    
    init(_ dates: Set<DateComponents>) {
        self.dates = dates
    }
    
}
