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
    var allDay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 && allDay == true) {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0 && allDay == true) {
            switch (indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "allDayCell", for: indexPath)
                cell.textLabel?.text = "All-Day"
                
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(allDay, animated: true)
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                cell.textLabel?.text = "Start Time"
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
                cell.textLabel?.text = "End Time"
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "allDayCell", for: indexPath)
                cell.textLabel?.text = ""
                return cell
            }
        }
        else if (indexPath.section == 0 && allDay == false) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "allDayCell", for: indexPath)
            cell.textLabel?.text = "All-Day"
            
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(allDay, animated: true)
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
            cell.textLabel?.text = "Calendar"
            return cell
        }
    }
    
    @objc func switchChanged(_ sender : UISwitch!) {
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        if (sender.isOn == true) {
            allDay = true
        } else {
            allDay = false
        }
        self.tableView.reloadData()
    }
}
