//
//  UserEventCell.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class UserEventCell: UITableViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var pickEntity: UILabel!
    @IBOutlet weak var wagerAmount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
