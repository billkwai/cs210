//
//  ActiveEventsTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class ActiveEventsTableViewController: UITableViewController {
    
    var activeEvents: [ActiveEvent]?
    var indexToPass = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        self.loadActiveEvents()
    }
    
    func loadActiveEvents() {
        
        if let user = SessionState.currentUser {
            
            
            DatabaseService.getActiveEvents(id: String(user.id)) { events in
                
                self.activeEvents = events
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
        if self.activeEvents == nil {
            return 0
        }
        return self.activeEvents!.count
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.ActiveEventCell, for: indexPath) as! ActiveEventCell
            if self.activeEvents != nil && self.activeEvents!.count >= indexPath.row {
                let event = self.activeEvents![indexPath.row]
                cell.team1Button.setTitle(event.entity1, for: .normal)
                cell.team2Button.setTitle(event.entity2, for: .normal)
                cell.oddsLabel.text = String(event.poolEntity1) + "/" + String(event.poolEntity2)
            }


        return cell
    }
 
    // alternate row colors
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? DetailedBetViewController {
            destinationVC.activeEvent = activeEvents?[indexToPass]
        }
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
