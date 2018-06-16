//
//  SYLBFormViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 6/14/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit

class SYLBFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var allDay = true
    var titleKey = "title"
    var dateKey = "date"
    var dataArray: [[String: Any]] = []
    var pickerIndex = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataArray = [
            [titleKey : "All-Day"]
        ]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return dataArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    // TODO: Change to TitleKey Switch statements
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            switch (dataArray[indexPath.row]["title"] as! String) {
            case "All-Day":
                let cell = tableView.dequeueReusableCell(withIdentifier: "allDayCell", for: indexPath)
                cell.textLabel?.text = "All-Day"
                
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(allDay, animated: true)
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                
                return cell
            case "Start Date":
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                cell.textLabel?.text = "Start Time"
                cell.detailTextLabel?.text = "10:00 AM"
                
                return cell
            case "End Date":
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                cell.textLabel?.text = "End Time"
                cell.detailTextLabel?.text = "11:15 AM"
                
                return cell
            case "Date Picker":
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "allDayCell", for: indexPath)
                cell.textLabel?.text = ""
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
            cell.textLabel?.text = "Calendar"
            return cell
        }
    }
    
    // STOPPED 6/16/2018 - implementing updating the date picker with the time above
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        let cell = tableView.cellForRow(at: indexPath)
        if (cell!.reuseIdentifier == "timeCell") {
            if (pickerIndex == indexPath.row + 1) {
                self.tableView.deleteRows(at: [IndexPath(row: pickerIndex, section: 0)], with: .fade)
                self.dataArray.remove(at: pickerIndex)
                self.pickerIndex = 100
            } else if (pickerIndex < dataArray.count) {
                self.tableView.deleteRows(at: [IndexPath(row: pickerIndex, section: 0)], with: .fade)
                self.dataArray.remove(at: pickerIndex)
                
                // Row numbers are different due to the removal above
                let row = pickerIndex < indexPath.row ? indexPath.row : indexPath.row + 1
                
                self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .fade)
                self.dataArray.insert([titleKey : "Date Picker"], at: row)
                self.pickerIndex = row
            } else {
                self.tableView.insertRows(at: [IndexPath(row: indexPath.row+1, section: 0)], with: .fade)
                self.dataArray.insert([titleKey : "Date Picker"], at: indexPath.row + 1)
                self.pickerIndex = indexPath.row + 1
            }
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (pickerIndex == indexPath.row) {
            return (tableView.dequeueReusableCell(withIdentifier: "datePickerCell")?.frame.height)!
        } else {
            return 44
        }
    }
    
    @IBAction func dateAction(_ sender: UIDatePicker) {
        let cellIndex = pickerIndex - 1
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell?.detailTextLabel?.text = dateFormatter.string(for: sender.date)
        
        self.dataArray[cellIndex][dateKey] = sender.date
    }
    
    // TODO: Remove rows with date picker
    @objc func switchChanged(_ sender : UISwitch!) {
        tableView.beginUpdates()
        if (sender.isOn == true) {
            allDay = true
            for index in 1...dataArray.count-1 {
                self.tableView.deleteRows(at: [IndexPath(row: dataArray.count-index, section: 0)], with: .fade)
            }
            self.dataArray = [
                [titleKey : "All-Day"]
            ]
            self.pickerIndex = 100
        } else {
            allDay = false
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            self.dataArray = [
                [titleKey : "All-Day"],
                [titleKey : "Start Date",
                 dateKey : Date()],
                [titleKey : "End Date",
                 dateKey : Date()]
            ]
        }
        tableView.endUpdates()
    }
}