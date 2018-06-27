//
//  SYLBTableViewViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 4/4/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class SYLBTableViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var syllabus = Syllabus()
    let dateFormatter = DateFormatter()
    
    // MARK: - Table view data source
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Review"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 25)!, NSAttributedStringKey.foregroundColor: UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)]
        
//        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editEvents))
//        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @IBAction func doneButton(_ sender: Any) {
        sendToCal()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return syllabus.assignments.count
    }
    
    //TODO: Check allDay variable to see if there is any dulplicates for efficiency
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        cell.assignmentLabel.text = syllabus.assignments[indexPath.row]
        cell.dayLabel.text = getDateString(date: syllabus.dates[indexPath.row], format: "E")
        cell.dateLabel.text = getDateString(date: syllabus.dates[indexPath.row], format: "MMM d")
        if (syllabus.allDay == true) {
            cell.timeLabel.text = ""
        } else {
            cell.timeLabel.text = getDateString(date: syllabus.dates[indexPath.row], format: "h:mm a")
        }
        cell.classLabel.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    
    //TODO: Add to global function
    func getDateString(date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    //TODO: Merge with above
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    @objc func editEvents() {
        
    }
    
    func sendToCal() {
        let eventStore = EKEventStore();
        
        for index in syllabus.dates.indices {
            let event:EKEvent = EKEvent(eventStore: eventStore)
            
            event.title = syllabus.assignments[index]
            if (syllabus.allDay == false) {
                event.startDate = getDatesWithTime(syllabusDate: syllabus.dates[index], time: syllabus.startTime)
                event.endDate = getDatesWithTime(syllabusDate: syllabus.dates[index], time: syllabus.endTime)
            } else {
                event.startDate = syllabus.dates[index]
                event.endDate = syllabus.dates[index]
                event.isAllDay = true
            }
            
            event.calendar = syllabus.selectedCalendar
            
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch let error as NSError {
                print("failed to save event with error : \(error)")
            }
        }
        
        // Closes VC
        dismiss(animated: true)
    }
    
    func getDatesWithTime(syllabusDate: Date, time: NSDate) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: syllabusDate as Date)
        dateComponents.month = calendar.component(.month, from: syllabusDate  as Date)
        dateComponents.day = calendar.component(.day, from: syllabusDate  as Date)
        dateComponents.hour = calendar.component(.hour, from: time  as Date)
        dateComponents.minute = calendar.component(.minute, from: time  as Date)
        
        let date = calendar.date(from: dateComponents)
        return date!
    }
}
