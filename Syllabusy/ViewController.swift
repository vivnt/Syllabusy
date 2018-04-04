//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 2/21/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SYLBUpload", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "navController")
        
        self.present(navVC, animated: true, completion: nil)
    }
}
