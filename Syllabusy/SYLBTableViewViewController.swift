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
    @IBOutlet var tableView: UITableView!

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return syllabus.assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
        cell.textLabel?.text = syllabus.assignments[indexPath.row]
        cell.detailTextLabel?.text = dateToString(date: syllabus.dates[indexPath.row])
        return cell
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func sendToCal() {
        
    }
}
