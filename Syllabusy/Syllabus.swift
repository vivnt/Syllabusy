//
//  Syllabus.swift
//  Syllabusy
//
//  Created by Vivian Tran on 4/3/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit

enum type {
    case date
    case assignment
}

enum OCRType {
    case date
    case assignment
}

struct Syllabus {
    var dates = [Date]()
    var assignments = [String]()
    var selectedCalendar = ""
}
