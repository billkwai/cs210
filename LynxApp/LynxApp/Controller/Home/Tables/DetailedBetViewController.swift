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
    var categoryImage: UIImage?
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @IBOutlet weak var poolSize: UILabel!
    
    @IBOutlet weak var decisionLabel: UILabel!
    @IBOutlet weak var wagerBox: UITextField!
    
    @IBOutlet weak var entity1Button: UIButton!
    
    @IBOutlet weak var entity2Button: UIButton!
    
    var eventManagedId: NSManagedObjectID?

    @IBOutlet weak var eventTitle: UILabel!
    
    
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
    
    var teamSelected = 1
    var selectionMade = false
    var entity1id:  Int?
    var bet = 50
    
    var entity2id:  Int?
    
    var outcome1: Outcome?
    var outcome2: Outcome?
    
    var title1 = ""
    var title2 = ""
    

    
    @IBAction func entity1Clicked(_ sender: Any) {
        entity1Button.backgroundColor = hexStringToUIColor(hex: "7D1A7D")
        entity2Button.backgroundColor = hexStringToUIColor(hex: "555555")
        decisionLabel.text = "You think " +  title1 + " will win"
        
        teamSelected = 1
        selectionMade = true
        updateWinning()

    }
    
    @IBAction func entity2Clicked(_ sender: Any) {
        
        entity2Button.backgroundColor = hexStringToUIColor(hex: "7D1A7D")
        entity1Button.backgroundColor = hexStringToUIColor(hex: "555555")
        decisionLabel.text = "You think " +  title2 + " will win"
        
        teamSelected = 2
        selectionMade = true
        updateWinning()

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
        
        if (DatabaseService.makePick(id: String(SessionState.currentUser!.id), betSize: (Int(round(sliderValue.value/50))*50), pickId: teamSelected, event: event!,
                                     id1: Int(entity1id!), id2: Int(entity2id!))) {
            
            event?.pickedOutcomeId = Int32(teamSelected)
            do {
                // Saves the entry updated
                try SessionState.coreDataManager.persistentContainer.viewContext.save()

            } catch {
                fatalError("Failure to save context: \(error)")
            }
            self.dismiss(animated: true, completion: nil)
            
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
        bet = Int(round(sender.value/50))*50
        if ((SessionState.currentUser?.coins)! < bet) {
            setSubmitStatus(canSubmit: false)
        } else {
            setSubmitStatus(canSubmit: true)
        }
        sliderLabel.text = "Your Wager: " + String(bet)
        if selectionMade{
            updateWinning()
        }

    }
    
    private func updateWinning(){
        let outcome1 = event?.outcomes![0] as? Outcome
        let outcome2 = event?.outcomes![1] as? Outcome
        
        var winnings = 0
        var total = Float((outcome1?.pool)!) + Float((outcome2?.pool)!)
        if teamSelected == 1{
            winnings = Int((total/Float((outcome1?.pool)!))*Float(bet))
        } else {
         winnings = Int((total/Float((outcome2?.pool)!))*Float(bet))
        }
        
        userBalance.text = "You stand to earn " + String(winnings) + " coins if correct"
        
    }
    
    private func secondsToDaysHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            event = try SessionState.coreDataManager.persistentContainer.viewContext.existingObject(with: eventManagedId!) as? Event
            
            if let image = categoryImage {
                eventImage.image = image
            }
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
            
            entity1Button.setTitle(outcome1?.title, for: .normal)
            entity2Button.setTitle(outcome2?.title, for: .normal)
            
            entity1Button.layer.cornerRadius = 5.0
            entity2Button.layer.cornerRadius = 5.0

            entity1Button.setTitle(outcome1?.title, for: .normal)
            entity2Button.setTitle(outcome2?.title, for: .normal)
            
                title1 = (outcome1?.title)!
                title2 = (outcome2?.title)!


        
            poolSize.text = "Pool Size:  " + String(describing: ((outcome1?.pool)! + (outcome2?.pool)!)) + " coins"
            
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
