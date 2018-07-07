//
//  SYLBFormCalendarViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 6/19/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class SYLBCalendarFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var mainViewController: SYLBFormViewController?
    var calendars: [EKCalendar]?
    var syllabus = Syllabus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eventStore = EKEventStore()
        self.calendars = eventStore.calendars(for: .event).sorted() { (cal1, cal2) -> Bool in
            if (cal1.title == "") {
                cal1.title = "Unknown Calendar Name"
            }
            return cal1.title < cal2.title
        }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            saveCalendar()
            mainViewController?.setCalendar(calendarName: syllabus.selectedCalendarName, calendar: syllabus.selectedCalendar)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Calendars"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = UIFont(name: "Helvetica", size: 13)!
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font=title.font
        header.textLabel!.textColor=title.textColor
        header.tintColor = UIColor(displayP3Red: 93/255, green: 93/255, blue: 93/255, alpha: 0.9)
        header.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calendars!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
        let calendarName = calendars![(indexPath as NSIndexPath).row].title
        cell.textLabel?.text = calendarName
        
        if (calendarName == syllabus.selectedCalendarName) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
        
        if cell.isSelected {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            syllabus.selectedCalendarName = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
        }
    }
    
    func saveCalendar() {
        for calendar in self.calendars! {
            if calendar.title == syllabus.selectedCalendarName {
                syllabus.selectedCalendar = calendar
                return
            }
        }
    }
}
