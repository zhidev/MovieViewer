//
//  MovieTCell.swift
//  MovieViewer
//
//  Created by Douglas on 1/24/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

class MovieTCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var posterView: UIImageView!
    @IBOutlet var overviewLabel: UILabel!
    	
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
