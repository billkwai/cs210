//
//  UserInfoTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var coinBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = SessionState.currentUser {
            SessionState.currentUser = DatabaseService.getUser(id: String(user.id))
            if let updatedUser = SessionState.currentUser {
                nameLabel.text = updatedUser.username
                coinBalanceLabel.text = String(updatedUser.coins)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
