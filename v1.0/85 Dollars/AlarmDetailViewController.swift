//
//  AlarmDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/13/23.
//

import UIKit

class AlarmDetailViewController: UIViewController {

    @IBOutlet var daySelectionButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    
    var numDays = 1
    let menuOptions = [
        "Day of cleaning",
        "1 day before cleaning",
        "2 days before cleaning",
        "3 days before cleaning",
        "4 days before cleaning",
        "5 days before cleaning",
        "6 days before cleaning",
        "1 week before cleaning"]
    
    var callback: ((_: Alarm?) -> Void)?
    var isPopup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeDatePicker()
        
        var menuChildren = [UIAction]()
        for (i, option) in menuOptions.enumerated() {
            menuChildren.append(UIAction(title: option, state: i == 1 ? .on : .off) { [weak self] action in
                if let days = self?.menuOptions.firstIndex(of: action.title) {
                    self?.numDays = days
                }
            })
        }
        daySelectionButton.menu = UIMenu(children: menuChildren)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(setAlarm))
        if isPopup {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            deleteButton.isHidden = true
        } else {
            deleteButton.setTitleColor(.red, for: .normal)
        }
    }
    
    func initializeDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: "17:00")
        guard let date = date else { return }
        datePicker.date = date
    }
    
    @objc func setAlarm() {
        if let callback = callback {
            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = calendar.dateComponents([.hour, .minute], from: datePicker.date)
            if let hour = dateComponents.hour, let minutes = dateComponents.minute {
                callback(Alarm(daysInAdvance: numDays, hour: hour, minute: minutes))
            } 
        } else {
            print("No alarm detail callback specified")
        }
        if isPopup {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let callback = callback {
            callback(nil)
            navigationController?.popViewController(animated: true)
        }
    }
}
