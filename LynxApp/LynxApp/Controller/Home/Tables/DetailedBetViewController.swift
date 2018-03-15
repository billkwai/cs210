//
//  DetailedBetViewController.swift
//  
//
//  Created by Akash Wadawadigi on 3/9/18.
//

import UIKit

class DetailedBetViewController: UIViewController {
    
    var activeEvent: ActiveEvent?
    var userInfo: User?

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
    
    @IBAction func selectedTeam(_ sender: UISegmentedControl) {
        switch chooseTeamSegmentedControl.selectedSegmentIndex {
        case 0:
            teamSelected = activeEvent?.idEntity1
            oddsOfSelectedTeam.text = "Consensus Odds: " + "\(activeEvent!.poolEntity1)" + ":" + "\(activeEvent!.poolEntity2)"
        case 1:
            teamSelected = activeEvent?.idEntity2
            oddsOfSelectedTeam.text = "Consensus Odds: " + "\(activeEvent!.poolEntity2)" + ":" + "\(activeEvent!.poolEntity1)"
        default:
            break
        }
    }
    
    
    @IBAction func submitForecast(_ sender: Any) {
        
        if (DatabaseService.makePick(id: String(SessionState.currentUser!.id), betSize: (Int(round(sliderValue.value/50))*50), pickId: teamSelected!, event: activeEvent!,
                                     id1: Int(entity1id!), id2: Int(entity2id!))) {
            
            performSegue(withIdentifier: StoryboardConstants.DetailToHome, sender: nil)
            
            
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
        if (SessionState.currentUser?.coins == 0) {
            setSubmitStatus(canSubmit: false)
        }
        
        let times = secondsToDaysHoursMinutesSeconds(seconds: (activeEvent?.expiresIn)!)
        
        if (times.0 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.0)" + " days"
        } else if (times.1 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.1)" + " hours"
        } else if (times.2 > 0) {
            betExpirationLabel.text = "Event expires in " + "\(times.2)" + " minutes"
        } else {
            betExpirationLabel.text = "Event expires in " + "1 minute"
        }
        
        teamSelected = activeEvent?.idEntity1
        
        entity1id = activeEvent?.idEntity1
        
        entity2id = activeEvent?.idEntity2
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity1, forSegmentAt: 0)
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity2, forSegmentAt: 1)


        oddsOfSelectedTeam.text = "Consensus Odds: " + "\(activeEvent!.poolEntity1)" + ":" + "\(activeEvent!.poolEntity2)"
        
        bettingCategoryLabel.text = activeEvent?.categoryName
        team1Label.text = activeEvent?.entity1
        team2Label.text = activeEvent?.entity2
        
        team1PotLabel.text = "Public Stake: " + String(describing: (activeEvent?.poolEntity1)!)
        team2PotLabel.text = "Public Stake: " + String(describing: (activeEvent?.poolEntity2)!)
        
        userBalance.text = "My Balance: " + "\(SessionState.currentUser!.coins)"
        
        eventTitle.text = activeEvent?.eventTitle


        // Do any additional setup after loading the view.
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
