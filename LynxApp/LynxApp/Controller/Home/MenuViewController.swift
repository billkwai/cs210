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

        updateUI()
        
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
        
        // add simple logout animation
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

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
    
    private func updateUI() {
        if let user = getUser() {
            DispatchQueue.main.async {
                
                self.nameLabel.text = user.firstName
                self.coinBalanceLabel.text = String(user.coins) + " coins"
            }
        }
    }
    
    private func getUser() -> User? {
        if SessionState.userNSObjectId == nil {
            if let id = SessionState.userId {
                if let user = fetchUser(id: id) {
                    SessionState.userNSObjectId = user.objectID
                    return user
                }
            }
        }
        do {
            if let user = try SessionState.coreDataManager.persistentContainer.viewContext.existingObject(with: SessionState.userNSObjectId!) as? User {
                    return user

            }
        } catch let error {
            print("NSObject not found from id error: \(error)")
        }
        return nil
    }
    
    
    @objc func updateData() {
        DatabaseService.updateUserEventData(id: String(SessionState.userId!), completion: { successGetUserEvents in
            if successGetUserEvents {
                DatabaseService.updateActiveEventData(id: String(SessionState.userId!), completion: { successGetActiveEvents in
                    if successGetActiveEvents {
                        DatabaseService.updateSocialData(completion: { successGetSocialData in
                            if successGetSocialData {
                                self.updateUI()
                            }
                        })
                    }
                })
            }
        })
    }
    
    
    

}

