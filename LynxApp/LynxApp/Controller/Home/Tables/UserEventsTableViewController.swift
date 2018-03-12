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
            switch (event.pickedEntity) {
            case event.idEntity1:
            cell.chosenTeamLabel.text = "\(event.entity1)"
            cell.opposingTeamLabel.text = "\(event.entity2)"
            cell.oddsLabel.text =  "\(event.poolEntity1)" + ":" + "\(event.poolEntity2)"
                break
            
            case event.idEntity2:
                cell.chosenTeamLabel.text = "\(event.entity2)"
                cell.opposingTeamLabel.text = "\(event.entity1)"
                cell.oddsLabel.text =  "\(event.poolEntity2)" + ":" + "\(event.poolEntity1)"
                break
            default:
                break
                
            }
            
            cell.coinDepositLabel.text = "0"
        }
        
        
        return cell
    }
    



}
