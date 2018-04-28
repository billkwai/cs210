//
//  MenuViewController.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coinBalanceLabel: UILabel!
    @IBOutlet weak var profileLabel: UIImageView!
    @IBOutlet weak var settingsLabel: UIImageView!
    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    var isLeftToRight = true
    
    var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = SessionState.userId {
            if let user = fetchUser(id: id) {
                // TODO: make this async
                SessionState.currentUser = user
                nameLabel.text = user.firstName
                coinBalanceLabel.text = String(user.coins)
                
            }
            DatabaseService.updateEventData(id: String(SessionState.userId!))
            DatabaseService.updateSocialData()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tapSettings))
        settingsLabel.isUserInteractionEnabled = true
        settingsLabel.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tapProfile))
        profileLabel.isUserInteractionEnabled = true
        profileLabel.addGestureRecognizer(tap2)
        
        updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)

        
    }
    
    private func fetchUser(id: Int) -> User? {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "id == %ld",id)
        
        do {
            let fetchedUsers = try SessionState.coreDataManager.persistentContainer.viewContext.fetch (userFetch) as! [User]
            if fetchedUsers.count > 0 {
                let user = fetchedUsers.first!
                return user
            }
        } catch {
            // error
        }
        return nil
    }
    
    
    @objc func updateData() {
        if let id = SessionState.userId {
            DatabaseService.updateEventData(id: String(id))
            DatabaseService.updateSocialData()
            DispatchQueue.main.async {
                if let user = SessionState.currentUser {

                    self.coinBalanceLabel.text = String(user.coins)
                }
            }
        }
    }
    
    
    func tapSettings(sender:UITapGestureRecognizer) {
       // self.openMenu()
    }
    
    func tapProfile(sender:UITapGestureRecognizer) {
        print("profile button clicked")
    }
    
    
    

}

