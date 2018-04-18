//
//  DetailedBetViewController.swift
//  
//
//  Created by Akash Wadawadigi on 3/9/18.
//

import UIKit
import CoreData

class DetailedBetViewController: UIViewController {
    
    @IBOutlet weak var eventImage: UIImageView!
    var event: Event?
    
    var eventManagedId: NSManagedObjectID?

    @IBOutlet weak var eventTitle: UILabel!
    
    @IBOutlet weak var bettingCategoryLabel: UILabel!
    
    @IBOutlet weak var betExpirationLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var team1Label: UILabel!
    
    @IBOutlet weak var team1PotLabel: UILabel!
    
    
    @IBOutlet weak var team2Label: UILabel!
    
    @IBOutlet weak var team2PotLabel: UILabel!
    
    @IBOutlet weak var oddsOfSelectedTeam: UILabel!
    
    @IBOutlet weak var chooseTeamSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var userBalance: UILabel!
    
    @IBOutlet weak var sliderValue: UISlider!
    
    var teamSelected: Int?
    
    var entity1id:  Int?
    
    var entity2id:  Int?
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func selectedTeam(_ sender: UISegmentedControl) {
        let outcome1 = event?.outcomes![0] as! Outcome
        let outcome2 = event?.outcomes![1] as! Outcome
        switch chooseTeamSegmentedControl.selectedSegmentIndex {
        case 0:
            teamSelected = Int(outcome1.id)
            oddsOfSelectedTeam.text = "Consensus Odds: " + "\(outcome1.pool)" + ":" + "\(outcome2.pool)"
        case 1:
            teamSelected = Int(outcome2.id)
            oddsOfSelectedTeam.text = "Consensus Odds: " + "\(outcome2.pool)" + ":" + "\(outcome1.pool)"
        default:
            break
        }
    }
    
    
    @IBAction func submitForecast(_ sender: Any) {
        
        if (DatabaseService.makePick(id: String(SessionState.currentUser!.id), betSize: (Int(round(sliderValue.value/50))*50), pickId: teamSelected!, event: event!,
                                     id1: Int(entity1id!), id2: Int(entity2id!))) {
            event?.pickedOutcomeId = Int32(teamSelected!)
            SessionState.saveCoreData()
            self.dismiss(animated: false, completion: nil)
            //performSegue(withIdentifier: StoryboardConstants.DetailToHome, sender: nil)
            
            
        } else {
            
            // report error
        }
        
        
        
    }
    
    @IBOutlet weak var sliderLabel: UILabel!
    
    private func setSubmitStatus(canSubmit: Bool) {
        if (canSubmit) {
            sliderLabel.textColor = UIColor.white
            submitButton.isEnabled = true
            submitButton.setTitleColor(AppTheme.detailViewPurple, for: .normal)
        } else {
            sliderLabel.textColor = UIColor.red
            submitButton.isEnabled = false
            submitButton.setTitleColor(AppTheme.lightGrey, for: .normal)

            
        }
    }
    
    
    @IBAction func wagerSlider(_ sender: UISlider) {
        let bet = Int(round(sender.value/50))*50
        if ((SessionState.currentUser?.coins)! < bet) {
            setSubmitStatus(canSubmit: false)
        } else {
            setSubmitStatus(canSubmit: true)
        }
        sliderLabel.text = "Foresight Stake: " + String(bet)
    }
    
    private func secondsToDaysHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            event = try SessionState.coreDataManager.managedObjectContext.existingObject(with: eventManagedId!) as? Event
        if (SessionState.currentUser?.coins == 0) {
            setSubmitStatus(canSubmit: false)
        }
            let times = secondsToDaysHoursMinutesSeconds(seconds: Int(event!.expiresIn))
        
        if (times.0 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.0)" + " days"
        } else if (times.1 > 1) {
            betExpirationLabel.text = "Event expires in " + "\(times.1)" + " hours"
        } else if (times.1 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.1)" + " hour"
        }
        else if (times.2 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.2)" + " minutes"
        } else {
            betExpirationLabel.text = "Event expires in " + "1 minute"
        }
        
            let outcome1 = event?.outcomes![0] as? Outcome
            let outcome2 = event?.outcomes![1] as? Outcome

        
        
        teamSelected = Int(outcome1!.id)
        
        entity1id = Int(outcome1!.id)
        
        entity2id = Int(outcome2!.id)
        chooseTeamSegmentedControl.setTitle(outcome1?.title, forSegmentAt: 0)
        chooseTeamSegmentedControl.setTitle(outcome2?.title, forSegmentAt: 1)


        oddsOfSelectedTeam.text = "Consensus Odds: " + "\(outcome1!.pool)" + ":" + "\(outcome2!.pool)"
        
            bettingCategoryLabel.text = event?.categoryName
        team1Label.text = outcome1?.title
        team2Label.text = outcome2?.title
        
        team1PotLabel.text = "Public Stake: " + String(describing: (outcome1?.pool)!)
        team2PotLabel.text = "Public Stake: " + String(describing: (outcome2?.pool)!)
        
        userBalance.text = "My Balance: " + "\(SessionState.currentUser!.coins)"
        
            eventTitle.text = event?.eventTitle

        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
