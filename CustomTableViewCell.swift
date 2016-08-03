//
//  CustomTableViewCell.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 02/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet var fileSizeLabel: UILabel!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
