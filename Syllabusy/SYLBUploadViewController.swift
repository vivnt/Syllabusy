//
//  SYLBUploadViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 2/23/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class SYLBUploadViewController: UIViewController {
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    
    // Created a button to test if calendar events are adding correctly.
    @IBAction func addButton(_ sender: Any) {
        let calendars = eventStore.calendars(for: EKEntityType.event)
        let calendar = calendars[0]
        // Use Event Store to create a new calendar instance
        let newEvent = EKEvent(eventStore: eventStore)
        
        let date = getDateObject(month: 02, day: 27, year: 2018, hour: 17, min: 0)
        newEvent.calendar = calendar
        newEvent.title = "Test"
        newEvent.startDate = Date()
        newEvent.endDate = date
        
        // Save the calendar using the Event Store instance
        
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // Gets the date object from inputted text 
    func getDateObject(month: Int, day: Int, year: Int, hour: Int, min: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = min
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        
        return date!
    }
}
