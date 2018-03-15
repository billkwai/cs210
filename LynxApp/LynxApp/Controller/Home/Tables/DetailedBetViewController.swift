//
//  DetailedBetViewController.swift
//  
//
//  Created by Akash Wadawadigi on 3/9/18.
//

import UIKit

class DetailedBetViewController: UIViewController {
    
    var activeEvent: ActiveEvent?

    var fullUnivNames = ["Stanford":"Stanford Cardinal", "Duke":"Duke Blue Devils", "USC":"USC Trojans", "UCLA":"UCLA Bruins", "California":"California Bears", "Michigan":"Michigan Wolverines"]
    
    @IBOutlet weak var bettingCategoryLabel: UILabel!
    
    @IBOutlet weak var betExpirationLabel: UILabel!
    
    @IBOutlet weak var team1Image: UIImageView!
    
    @IBOutlet weak var team1Label: UILabel!
    
    @IBOutlet weak var team1PotLabel: UILabel!
    
    @IBOutlet weak var team2Image: UIImageView!
    
    @IBOutlet weak var team2Label: UILabel!
    
    @IBOutlet weak var team2PotLabel: UILabel!
    
    @IBOutlet weak var oddsOfSelectedTeam: UILabel!
    
    @IBOutlet weak var chooseTeamSegmentedControl: UISegmentedControl!
    
    
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
    
    @IBAction func wagerSlider(_ sender: UISlider) {
        sliderLabel.text = "Foresight Stake: " + String(Int(round(sender.value/50))*50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamSelected = activeEvent?.idEntity1
        
        entity1id = activeEvent?.idEntity1
        
        entity2id = activeEvent?.idEntity2
        
        let team1ImageName = (activeEvent?.entity1.lowercased())! + ".png"
        let team2ImageName = (activeEvent?.entity2.lowercased())! + ".png"
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity1, forSegmentAt: 0)
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity2, forSegmentAt: 1)


        oddsOfSelectedTeam.text = "Consensus Odds: " + "\(activeEvent!.poolEntity1)" + ":" + "\(activeEvent!.poolEntity2)"
        
        team1Image.image = UIImage(named:team1ImageName)
        team2Image.image = UIImage(named:team2ImageName)
        team1Label.text = activeEvent?.entity1
        team2Label.text = activeEvent?.entity2

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
