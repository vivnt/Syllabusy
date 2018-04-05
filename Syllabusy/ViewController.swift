//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 2/21/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    let eventStore = EKEventStore()
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SYLBUpload", bundle: nil)
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
