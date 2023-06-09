//
//  ScheduleDetailViewController.swift
//  85 Dollars
//
//  Created by George Birch on 6/8/23.
//

import UIKit

class ScheduleDetailViewController: UITableViewController {
    
    var schedule: Schedule!
    
//    init(schedule: Schedule = Schedule(weekdays: Set<Weekday>(), weeks: Set<Rotation>())) {
//        self.schedule = schedule
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required convenience init?(coder: NSCoder) {
//        self.init()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schedule = schedule ?? Schedule(weekdays: Set<Weekday>(), weeks: Set<Rotation>())
        
        navigationItem.rightBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Cleaning days" : "Alarms"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: implement method
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
