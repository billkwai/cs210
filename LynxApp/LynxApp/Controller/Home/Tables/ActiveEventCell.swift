//
//  EventCell.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/15/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ActiveEventCell: UITableViewCell {

    @IBOutlet weak var team1Button: UIButton!    
    @IBOutlet weak var team2Button: UIButton!
    @IBOutlet weak var oddsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func team1Selected(_ sender: Any) {
        // TODO
    }
    
    @IBAction func team2Selected(_ sender: Any) {
        // TODO
    }
}
