//
//  LeaderboardTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class LeaderboardTableViewController: UITableViewController {

    var users: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUsers()
    }
    
    func loadUsers() {

        DatabaseService.getLeaderboard() { leaders in
            
            DispatchQueue.main.async {
                self.users = leaders
                self.tableView.reloadData()
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Leaderboard"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil {
            return 0
        }
        return self.users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.LeaderboardCell, for: indexPath) as! LeaderboardCell
        if self.users != nil && self.users!.count >= indexPath.row {
            let user = self.users![indexPath.row]
            cell.rankLabel.text = String(indexPath.row + 1) // right now assumes users ordered from greatest to least
            cell.nameLabel.text = user.username
            cell.coinsLabel.text = String(user.coins)
        
        }
        
        
        return cell
    }
    
    // alternate row colors
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = AppTheme.fadedPurple
        } else {
            cell.backgroundColor = UIColor.white
        }
    }


}
