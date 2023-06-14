//
//  AlarmDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/13/23.
//

import UIKit

class AlarmDetailViewController: UIViewController {

    @IBOutlet var daySelectionButton: UIButton!
    
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
    
    var callback: ((_: TimeInterval) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    @objc func setAlarm() {
        if let callback = callback {
            // TODO: implement math to get alarm
        } else {
            print("No alarm detail callback specified")
        }
        navigationController?.popViewController(animated: true)
    }

}
