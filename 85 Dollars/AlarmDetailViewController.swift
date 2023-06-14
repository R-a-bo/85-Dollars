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
    
    var callback: ((_: TimeInterval?) -> Void)?
    var isPopup = false
    
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
        if isPopup {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            deleteButton.isHidden = true
        } else {
            deleteButton.setTitleColor(.red, for: .normal)
        }
    }
    
    @objc func setAlarm() {
        if let callback = callback {
            //TODO: implement alarm math
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
        //TODO: delete alarm so that nil is returned
        setAlarm()
    }
}
