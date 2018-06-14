//
//  SYLBTableViewViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 4/4/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit

class SYLBReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var syllabus = Syllabus()
    var type = OCRType.date
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
}
