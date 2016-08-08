//
//  Custom1TableViewCell.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import UIKit

class Custom1TableViewCell: UITableViewCell {
    
    
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    
    @IBOutlet var fileSizeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
