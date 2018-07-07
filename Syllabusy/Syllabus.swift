//
//  Syllabus.swift
//  Syllabusy
//
//  Created by Vivian Tran on 4/3/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

enum type {
    case date
    case assignment
}

struct Syllabus {
    var dates = [Date]()
    var assignments = [String]()
    var selectedCalendarName = ""
    var selectedCalendar: EKCalendar
    var allDay = true
    var startTime = NSDate()
    var endTime = NSDate()
    
    init() {
        let eventStore = EKEventStore();
        self.selectedCalendar = eventStore.defaultCalendarForNewEvents!
        self.selectedCalendarName = self.selectedCalendar.title
    }
}


