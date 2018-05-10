//
//  SocialScreenViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 5/9/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}

class SocialScreenViewController: UIViewController {

    @IBOutlet weak var weeklyWinsLabel: UILabel!
    
    @IBOutlet weak var allWinsLabel: UILabel!
    
    @IBOutlet weak var accuracyLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    
    var updateTimer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
        
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getStats), userInfo: nil, repeats: true)
        
        getStats()
    }
    
    private func setEmpty() {
        allWinsLabel.text = "0"
        weeklyWinsLabel.text = "0"
        
        accuracyLabel.text = "0.0"
        rankLabel.text = "0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func getStats() {
        if let id = SessionState.userId {
            
            if let userStats = fetchUserStats(id: id) {
                allWinsLabel.fadeTransition(0.4)
                allWinsLabel.text = String(userStats.correctEver)
                
                weeklyWinsLabel.fadeTransition(0.4)
                weeklyWinsLabel.text = String(userStats.correctWeekly)
                
                accuracyLabel.fadeTransition(0.4)
                accuracyLabel.text = String(Float(userStats.correctEver)/Float(userStats.incorrectEver + userStats.correctEver))
                
                if let user = userStats.user {
                    rankLabel.fadeTransition(0.4)
                    rankLabel.text = String(user.score)
                } else {
                    rankLabel.text = "0"
                }
                
                
            } else {
                setEmpty()
            }
            
        } else {
            setEmpty()
        }
    }
    private func fetchUserStats(id: Int) -> UserStats? {
        let userStatsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserStats")
        userStatsFetch.predicate = NSPredicate(format: "user.id == %ld",id)
        
        do {
            let fetchedUserStats = try SessionState.coreDataManager.persistentContainer.viewContext.fetch (userStatsFetch) as! [UserStats]
            if fetchedUserStats.count > 0 {
                let userStats = fetchedUserStats.first!
                return userStats
            }
        } catch {
            // error
        }
        return nil
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
