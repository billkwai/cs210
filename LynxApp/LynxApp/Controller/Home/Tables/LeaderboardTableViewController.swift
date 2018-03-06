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

        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        self.loadUsers()
    }
    
    func loadUsers() {
        // will need to be async
        // will need POST that fetches top "20" users, or top 20 friends
        users = DatabaseService.fetchTestUsers(json: TestData.users)
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
            cell.nameLabel.text = user.firstName + " " + user.lastName
            cell.coinsLabel.text = String(user.coins)
        
        }
        
        
        return cell
    }


}
