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
    
    var chosenBetIndex = 0
    var teamSelected = "Team 1"
    var team1:String?
    var team2:String?
    var oddsTeam1:Int?
    var oddsTeam2:Int?
    
    
    @IBAction func selectedTeam(_ sender: UISegmentedControl) {
        switch chooseTeamSegmentedControl.selectedSegmentIndex{
        case 0:
            teamSelected = team1!
            oddsOfSelectedTeam.text = "Consensus Odds: " +    String(oddsTeam1!) + ":" + String(oddsTeam2!)
        case 1:
            teamSelected = team2!
            oddsOfSelectedTeam.text = "Consensus Odds: " +    String(oddsTeam2!) + ":" + String(oddsTeam1!)
        default:
            break
        }
    }
    @IBAction func submitForecast(_ sender: Any) {
    }
    @IBOutlet weak var sliderLabel: UILabel!
    @IBAction func wagerSlider(_ sender: UISlider) {
        sliderLabel.text = "Foresight Stake: " + String(Int((round(sender.value/50))*50))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let team1ImageName = (activeEvent?.entity1.lowercased())! + ".png"
        let team2ImageName = (activeEvent?.entity2.lowercased())! + ".png"
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity1, forSegmentAt: 0)
        chooseTeamSegmentedControl.setTitle(activeEvent?.entity2, forSegmentAt: 1)

        team1 = fullUnivNames[(activeEvent?.entity1)!]
        team2 = fullUnivNames[(activeEvent?.entity2)!]
        oddsTeam1 = activeEvent?.poolEntity1
        oddsTeam2 = activeEvent?.poolEntity2
        oddsOfSelectedTeam.text = "Consensus Odds: " +    String(describing: activeEvent?.poolEntity1) + ":" + String(describing: activeEvent?.poolEntity2)
        team1Image.image = UIImage(named:team1ImageName)
        team2Image.image = UIImage(named:team2ImageName)
        team1Label.text = team1
        team2Label.text = team2

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
