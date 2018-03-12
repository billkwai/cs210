//
//  UserEventsTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class UserEventsTableViewController: UITableViewController {

    var userEvents: [UserEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        self.loadUserEvents()
    }
    
    func loadUserEvents() {

        if let user = SessionState.currentUser {
            DatabaseService.getUserEvents(id: String(user.id)) { events in
                
                self.userEvents = events
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }                
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
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userEvents == nil {
            return 0
        }
        return self.userEvents!.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.UserEventCell, for: indexPath) as! UserEventCell
        if self.userEvents != nil && self.userEvents!.count >= indexPath.row {
            
            let event = self.userEvents![indexPath.row]
            //cell.chosenTeamLabel.text = event.chosenTeam
            //cell.opposingTeamLabel.text = event.opposingTeam
           // cell.oddsLabel.text = String(event.oddsChosenTeam) + "/" + String(event.oddsOpposingTeam)
            //cell.coinDepositLabel.text = String(event.coinDeposit)
        }
        
        
        return cell
    }
    



}
