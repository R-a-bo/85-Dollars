//
//  PatternSelectionViewController.swift
//  85 Dollars
//
//  Created by George Birch on 7/25/23.
//

import UIKit

class PatternSelectionViewController: UITableViewController {
    
    var selection = [Bool]()
    var callback: ((_: [Bool]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callback?(selection)
    }
    
    func cellTitle(for index: Int) -> String {
        return String(index)
    }
    
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selection.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selection", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = cellTitle(for: indexPath.row)
        cell.contentConfiguration = content
        
        let finalItemAndAllSelected = indexPath.row == selection.count && selection.allSatisfy({$0})
        let isSelected = indexPath.row < selection.count && selection[indexPath.row]
        if finalItemAndAllSelected || isSelected {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            if indexPath.row == selection.count {
                for i in 0..<selection.count {
                    selection[i] = false
                    let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))
                    otherCell?.accessoryType = .none
                }
            } else {
                selection[indexPath.row] = false
                let finalCell = tableView.cellForRow(at: IndexPath(row: selection.count, section: indexPath.section))
                finalCell?.accessoryType = .none
            }
        } else {
            cell?.accessoryType = .checkmark
            if indexPath.row == selection.count {
                for i in 0..<selection.count {
                    selection[i] = true
                    let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))
                    otherCell?.accessoryType = .checkmark
                }
            } else {
                selection[indexPath.row] = true
                var allSelected = true
                for i in 0..<selection.count {
                    if !selection[i] {
                        allSelected = false
                    }
                }
                if allSelected {
                    let finalCell = tableView.cellForRow(at: IndexPath(row: selection.count, section: indexPath.section))
                    finalCell?.accessoryType = .checkmark
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
