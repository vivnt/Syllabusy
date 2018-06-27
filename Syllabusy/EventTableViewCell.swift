//
//  EventTableViewCell.swift
//  Syllabusy
//
//  Created by Vivian Tran on 6/26/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet var view: UIView!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var assignmentLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.8
    }

}
