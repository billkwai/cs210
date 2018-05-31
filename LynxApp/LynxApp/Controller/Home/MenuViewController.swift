//
//  MenuViewController.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData
import FacebookLogin

class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coinBalanceLabel: UILabel!
    
    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    
    var overlay: UIVisualEffectView?
    
    var isLeftToRight = true
    var logIn = false
    
    var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tapLogout))
        logoutLabel.isUserInteractionEnabled = true
        logoutLabel.addGestureRecognizer(tap)
        
        
        updateTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        
        if logIn {
            addOverlay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    
    @objc func tapLogout(sender: AnyObject) {
        let _ = KeychainWrapper.standard.removeAllKeys()
        
        // added this logOut() function to fix login issues
        LoginManager().logOut()
        
        updateTimer.invalidate()
        
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
        self.view.removeFromSuperview()

    }
    
    @objc func tapOverlayButton(sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: {self.overlay?.alpha = 0.0},
                                   completion: {(value: Bool) in
                                    self.overlay?.removeFromSuperview()
        })
    }
    
    private func addOverlay() {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            overlay = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            overlay?.frame = self.view.bounds
            overlay?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let buttonHeight: CGFloat = 40
            let buttonWidth: CGFloat = 200
            
            // Add a custom login button to your app
            let overlayButton = UIButton(type: .custom)
            overlayButton.backgroundColor = UIColor.purple
            overlayButton.frame = CGRect(x:view.center.x - buttonWidth/2, y:view.center.y + 8*buttonHeight/2, width:buttonWidth, height:buttonHeight);
            overlayButton.setTitle("Start Predicting...", for: .normal)
            overlayButton.titleLabel?.font = nameLabel.font
            overlayButton.layer.cornerRadius = 5
            // Handle clicks on the button
            overlayButton.addTarget(self, action: #selector(self.tapOverlayButton), for: .touchUpInside)
            overlay?.contentView.addSubview(overlayButton)
            
            let labelHeight: CGFloat = 30
            let labelWidth: CGFloat = 300
            
            let labelLeft = UILabel(frame: CGRect(x: view.center.x - labelWidth/2, y: view.center.y - 2*labelHeight/2, width: labelWidth, height: labelHeight))
            //labelLeft.center = CGPoint(x: 160, y: 285)
            labelLeft.textAlignment = .center
            labelLeft.text = "Swipe right to find new events"
            labelLeft.font = nameLabel.font
            labelLeft.textColor = UIColor.purple
            overlay?.contentView.addSubview(labelLeft)
            
            let labelRight = UILabel(frame: CGRect(x: view.center.x - labelWidth/2, y: view.center.y + labelHeight/2, width: labelWidth, height: labelHeight))
            //labelRight.center = CGPoint(x: 160, y: 300)
            labelRight.textAlignment = .center
            labelRight.text = "Swipe left to see how you stack up"
            labelRight.font = nameLabel.font
            labelRight.textColor = UIColor.purple
            overlay?.contentView.addSubview(labelRight)
            
            view.addSubview(overlay!)
        } else {
            view.backgroundColor = .black
        }
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
                self.coinBalanceLabel.text = String(Int(user.score)) + " Reputation"
                if user.score > 0 {
                    self.coinBalanceLabel.textColor = UIColor.green
                } else if user.score < 0 {
                    self.coinBalanceLabel.textColor = UIColor.red
                }
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
                            if successGetActiveEvents {
                                DatabaseService.getUser(id: String(SessionState.userId!), completion: { successGetUser in
                                    if successGetUser {
                                        self.updateUI()
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    
    

}

