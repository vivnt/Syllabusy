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
    var syllabus = Syllabus()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = "Syllabusy"
        
        view.bringSubview(toFront: uploadButton)
    }
    let eventStore = EKEventStore()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        cell.textLabel?.text = "Event"
        return cell
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SYLBForm", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "navController")
        
        self.present(navVC, animated: true, completion: nil)
    }
    
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
