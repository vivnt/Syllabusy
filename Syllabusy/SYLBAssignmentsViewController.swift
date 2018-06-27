//
//  SYLBAssignmentsViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 2/23/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class SYLBAssignmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var calendarTableView: UITableView!
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    
    override func viewWillAppear(_ animated: Bool) {
        checkEventKitAuthorization();
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
            // Things are in line with being able to show the calendars in the table view
            loadCalendars()
            refreshTableView()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
            // We need to help them give us permission
        }
    }
    
    // TODO: Change
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                self.loadCalendars()
                self.refreshTableView()
            }
        })
    }
    
    // Grabs the list of calendars
    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
    }
    
    func refreshTableView() {
        calendarTableView.isHidden = false
        calendarTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card") as! SYLBCardTableViewCell
        if let calendars = self.calendars {
            let calendarName = calendars[(indexPath as NSIndexPath).row].title
            cell.classLabel.text = calendarName
        } else {
            cell.classLabel?.text = "Untitled Calendar"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}

