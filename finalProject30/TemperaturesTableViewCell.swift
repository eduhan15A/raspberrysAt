//
//  TemperaturesTableViewCell.swift
//  finalProject30
//
//  Created by Eduardo Lujan on 27/04/18.
//  Copyright © 2018 Eduardo Lujan. All rights reserved.
//

import UIKit

class TemperaturesTableViewCell: UITableViewCell {

    @IBOutlet weak var id: UILabel!
    
    @IBOutlet weak var device: UILabel!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var temperature: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
