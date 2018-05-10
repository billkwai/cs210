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
    
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coinBalanceLabel: UILabel!
    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    var isLeftToRight = true
    
    var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StoryboardConstants.backgroundColor1

        if let id = SessionState.userId {
            if let user = fetchUser(id: id) {
                // TODO: make this async
                SessionState.currentUser = user
                nameLabel.text = user.firstName
                coinBalanceLabel.text = String(user.coins) + " coins"
                
            }
            DatabaseService.updateEventData(id: String(SessionState.userId!))
            DatabaseService.updateSocialData()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tapLogout))
        logoutLabel.isUserInteractionEnabled = true
        logoutLabel.addGestureRecognizer(tap)
        
        
        updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)

        
    }
    
    @objc func tapLogout(sender: AnyObject) {
        let _ = KeychainWrapper.standard.removeAllKeys()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginPageVC = mainStoryboard.instantiateViewController(withIdentifier: StoryboardConstants.LoginPageVC) as! LoginPageViewController
        UIApplication.shared.keyWindow?.rootViewController = loginPageVC
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)

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

                    self.coinBalanceLabel.text = String(user.coins) + " coins"
                }
            }
        }
    }
    
    
    

}

