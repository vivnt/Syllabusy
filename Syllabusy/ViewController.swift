//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 2/21/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var uploadButton: UIButton!
    let eventStore = EKEventStore()
    lazy var syllabus = Syllabus()
    var calendars = [EKCalendar]()
    var events = [EKEvent]()
    let dateFormatter = DateFormatter()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkEventKitAuthorization();
        
        //        tableView.isHidden = true
        
        self.title = "Syllabusy"
        
        getEvents()
        
        view.bringSubview(toFront: uploadButton)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 25)!, NSAttributedStringKey.foregroundColor: UIColor(red: 188/255, green: 110/255, blue: 255/255, alpha: 1)]
    }
    
    func getEvents() {
        self.calendars = EKEventStore().calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
            return cal1.title < cal2.title
        }
        let oneMonthAhead = Calendar.current.date(byAdding: .month, value: 4, to: Date())
        
        let eventsPredicate = eventStore.predicateForEvents(withStart: Date(), end: oneMonthAhead!, calendars: self.calendars)
        self.events = eventStore.events(matching: eventsPredicate).sorted {
            (e1: EKEvent, e2: EKEvent) in
            
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "TODAY"
        } else {
            return "UPCOMING"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        cell.assignmentLabel.text = events[indexPath.row].title
        cell.dayLabel.text = getDateString(date: events[indexPath.row].startDate, format: "E")
        cell.dateLabel.text = getDateString(date: events[indexPath.row].startDate, format: "MMM d")
        if (events[indexPath.row].isAllDay == true) {
            cell.timeLabel.text = ""
        } else {
            cell.timeLabel.text = getDateString(date: events[indexPath.row].startDate, format: "h:mm a")
        }
        cell.classLabel.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = UIFont(name: "Helvetica", size: 13)!
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font=title.font
        header.textLabel!.textColor=title.textColor
        header.contentView.backgroundColor = UIColor.white
    }
    
    //TODO: Add to global function
    func getDateString(date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SYLBForm", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "navController")
        
        self.present(navVC, animated: true, completion: nil)
    }
    
    // Checks if Event Kit has authorization
    // TODO: Change
    func checkEventKitAuthorization() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            break
        // Things are in line with being able to show the calendars in the table view
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
            // We need to help them give us permission
        }
    }
    
    // TODO: Change
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
        })
    }
}
