//
//  SYLBFormViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 6/14/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class SYLBFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var allDay = true
    var titleKey = "title"
    var dateKey = "date"
    let dateFormatter = DateFormatter()
    var dataArray: [[String: Any]] = []
    var pickerIndex = 100
    var syllabus = Syllabus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.dataArray = [
            [titleKey : "All-Day"]
        ]
        
        dateFormatter.dateFormat = "h:mm a"
    }
    
    @objc func nextAction() {
        let uploadVC = UIStoryboard(name: "SYLBUpload", bundle: nil).instantiateViewController(withIdentifier: "uploadVC") as! SYLBUploadViewController
        uploadVC.syllabus = syllabus
        if (allDay == false) {
            syllabus.allDay = allDay
            syllabus.startTime = dataArray[1]["date"] as! NSDate
            syllabus.endTime = dataArray[2]["date"] as! NSDate
        }
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
                cell.detailTextLabel?.text = dateFormatter.string(from: self.dataArray[indexPath.row]["date"] as! Date)
                
                return cell
            case "End Date":
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                cell.textLabel?.text = "End Time"
                cell.detailTextLabel?.text = dateFormatter.string(from: self.dataArray[indexPath.row]["date"] as! Date)
                
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
            cell.detailTextLabel?.text = syllabus.selectedCalendarName
            return cell
        }
    }
    
    func updateDatePicker() {
        if pickerIndex < dataArray.count-1 {
            let associatedDatePickerCell = self.tableView.cellForRow(at: IndexPath(item: pickerIndex, section: 0))
            guard let targetedDatePicker = associatedDatePickerCell?.viewWithTag(99) as? UIDatePicker else {return}
            targetedDatePicker.setDate(dataArray[pickerIndex-1]["date"] as! Date, animated: false)
        }
    }
    
    func setCalendar(calendarName: String, calendar: EKCalendar) {
        syllabus.selectedCalendarName = calendarName
        syllabus.selectedCalendar = calendar
    }
    
    // TODO: Call back from unwind needs to send data over
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let calendarForm = UIStoryboard(name: "SYLBForm", bundle: nil).instantiateViewController(withIdentifier: "calendarFormVC") as! SYLBCalendarFormViewController
            calendarForm.syllabus = syllabus
            calendarForm.mainViewController = self
            self.navigationController?.pushViewController(calendarForm, animated: true)
        } else {
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
            
            self.updateDatePicker()
        }
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
        sender.tag = 99
        let cellIndex = pickerIndex - 1
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0))
        cell?.detailTextLabel?.text = self.dateFormatter.string(for: sender.date)
        
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
            syllabus.allDay = false
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
