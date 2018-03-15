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
        
        self.loadUserEvents()
    }
    
    func loadUserEvents() {

        if let user = SessionState.currentUser {
            DatabaseService.getUserEvents(id: String(user.id)) { events in
                
                DispatchQueue.main.async {
                    self.userEvents = events
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Picks"
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userEvents == nil {
            // Adds a label when user has no picks and table is empty
//            let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
//            emptyLabel.text = "Swipe left to discover more events!"
//            emptyLabel.textAlignment = NSTextAlignment.center
//            self.tableView.backgroundView = emptyLabel
//            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        } else {
            // self.tableView.backgroundView?.isHidden = true
            return self.userEvents!.count
        }
    }
    
    // Alternates the row colors
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = AppTheme.fadedPurple
        } else {
            cell.backgroundColor = UIColor.white
        }
    }

    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.UserEventCell, for: indexPath) as! UserEventCell
        if self.userEvents != nil && self.userEvents!.count >= indexPath.row {
            
            let event = self.userEvents![indexPath.row]
            switch (event.pickedEntity) {
                
            case event.idEntity1:
                cell.pickEntity.text = "\(event.entity1)"
                break
            
            case event.idEntity2:
                cell.pickEntity.text = "\(event.entity2)"
                break
            default:
                break
                
            }
            
            cell.wagerAmount.text = "\(event.betSize)" + "\u{A2}"
            cell.eventTitle.text = "\(event.eventTitle)"
        }
        
        
        return cell
    }
    


}
