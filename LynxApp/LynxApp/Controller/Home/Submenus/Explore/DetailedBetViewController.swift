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
    
    @IBOutlet weak var backLabel: UILabel!
    
    @IBOutlet weak var poolSize: UILabel!
    
    @IBOutlet weak var decisionLabel: UILabel!
    
    @IBOutlet weak var entity1Button: UIButton!
    
    @IBOutlet weak var entity2Button: UIButton!
    
    var eventManagedId: NSManagedObjectID?

    @IBOutlet weak var eventTitle: UILabel!
    
    
    @IBOutlet weak var betExpirationLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var userBalance: UILabel!
    
    @IBOutlet weak var sliderValue: UISlider!
    
    
    @IBOutlet weak var oddsBarView: UIView!
    
    var teamSelected = 1
    var selectionMade = false
    var entity1id:  Int?
    var bet = 50
    
    var entity2id:  Int?
    
    var outcome1: Outcome?
    var outcome2: Outcome?
    
    var title1 = ""
    var title2 = ""
    
    var userCoins = 0
    var userId = 0
    
    private func hexStringToUIColor (hex:String) -> UIColor {
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
    
    //citation link: https://stackoverflow.com/questions/39215050/how-to-make-a-custom-progress-bar-in-swift-ios
    let viewCornerRadius : CGFloat = 5
    var borderLayer : CAShapeLayer = CAShapeLayer()
    let progressLayer : CAShapeLayer = CAShapeLayer()
    
    func drawProgressLayer(){
        
        let bezierPath = UIBezierPath(roundedRect: oddsBarView.bounds, cornerRadius: viewCornerRadius)
        bezierPath.close()
        borderLayer.path = bezierPath.cgPath
        borderLayer.fillColor = UIColor(red:0.51, green:0.53, blue:0.54, alpha:1.0).cgColor
        borderLayer.strokeEnd = 0
        oddsBarView.layer.addSublayer(borderLayer)
        
        
    }
    
    //Make sure the value that you want in the function `rectProgress` that is going to define
    //the width of your progress bar must be in the range of
    // 0 <--> viewProg.bounds.width - 10 , reason why to keep the layer inside the view with some border left spare.
    //if you are receiving your progress values in 0.00 -- 1.00 range , just multiply your progress values to viewProg.bounds.width - 10 and send them as *incremented:* parameter in this func
    
    func rectProgress(incremented : CGFloat){
        if incremented <= oddsBarView.bounds.width - 10{
            progressLayer.removeFromSuperlayer()
            let bezierPathProg = UIBezierPath(roundedRect: CGRect(x: CGFloat(5), y: CGFloat(5), width: incremented, height: oddsBarView.bounds.height - 10) , cornerRadius: viewCornerRadius)
            bezierPathProg.close()
            progressLayer.path = bezierPathProg.cgPath
            progressLayer.fillColor = UIColor.white.cgColor
            borderLayer.addSublayer(progressLayer)
        }
    }
    

    
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
    
    
    
    @IBAction func submitForecast(_ sender: Any) {
        
        if (DatabaseService.makePick(id: String(userId), betSize: (Int(round(sliderValue.value/50))*50), pickId: teamSelected, event: event!,
                                     id1: Int(entity1id!), id2: Int(entity2id!))) {
            
            SessionState.coreDataManager.persistentContainer.viewContext.perform {
                self.event?.pickedOutcomeId = Int32(self.teamSelected)
                do {
                    // Saves the data from the child to the main context to be stored properly
                    try SessionState.coreDataManager.persistentContainer.viewContext.save()
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
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
        if (userCoins < bet) {
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
        let total = Float((outcome1?.pool)!) + Float((outcome2?.pool)!)
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
    
    @objc func tapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBack))
        backLabel.isUserInteractionEnabled = true
        backLabel.addGestureRecognizer(tap)
        
        if let id = SessionState.userNSObjectId {
            do {
                if let user = try SessionState.coreDataManager.persistentContainer.viewContext.existingObject(with: id) as? User {
                    
                    userCoins = Int(user.coins)
                    userId = Int(user.id)

                }
            } catch let error {
                print("NSObject not found from id error: \(error)")
            }
        }
        
        do {
            event = try SessionState.coreDataManager.persistentContainer.viewContext.existingObject(with: eventManagedId!) as? Event
            
            if let image = categoryImage {
                eventImage.image = image
            }
            if (userCoins == 0) {
                setSubmitStatus(canSubmit: false)
            }
            let times = secondsToDaysHoursMinutesSeconds(seconds: Int(event!.expiresIn))
            
            if (times.0 == 1) {
                betExpirationLabel.text = "Event expires in " + "\(times.0)" + " day"
            } else if (times.0 > 0) {
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

            
            drawProgressLayer()
            // incremented is how much the progress bar shows based on team 1's pool size relative to the whole pool
            let odds = CGFloat((outcome1?.pool)!)/CGFloat((outcome1?.pool)! + (outcome2?.pool)!)
            rectProgress(incremented: (odds * (oddsBarView.bounds.width - 10)))
            
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
