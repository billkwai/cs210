//
//  DetailedBetViewController.swift
//  
//
//  Created by Akash Wadawadigi on 3/9/18.
//

import UIKit
import CoreData
import Firebase

class DetailedBetViewController: UIViewController {
    
    @IBOutlet weak var eventImage: UIImageView!
    var event: Event?
    var categoryImage: UIImage?
    
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var poolSize: UILabel!
    @IBOutlet weak var decisionLabel: UILabel!
    @IBOutlet weak var scoreOutcome1Label: UILabel!
    @IBOutlet weak var scoreOutcome2Label: UILabel!
    
    
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
    var bet = 5
    
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
    let viewCornerRadius : CGFloat = 10
    var borderLayer : CAShapeLayer = CAShapeLayer()
    let progressLayer : CAShapeLayer = CAShapeLayer()
    
    func drawProgressLayer(){
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: 10, y: 5, width: oddsBarView.bounds.width - 20, height: oddsBarView.bounds.height - 5), cornerRadius: viewCornerRadius)
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
            if (incremented >= oddsBarView.bounds.width - 20 - incremented) {
                let bezierPathProg = UIBezierPath(roundedRect: CGRect(x: 10, y: 5, width: incremented, height: oddsBarView.bounds.height - 5) , cornerRadius: viewCornerRadius)
                bezierPathProg.close()
                progressLayer.path = bezierPathProg.cgPath
                progressLayer.fillColor = UIColor.purple.cgColor
                borderLayer.addSublayer(progressLayer)
            } else {
                let bezierPathProg = UIBezierPath(roundedRect: CGRect(x: 10 + incremented, y: 5, width: oddsBarView.bounds.width - 20 - incremented, height: oddsBarView.bounds.height - 5) , cornerRadius: viewCornerRadius)
                bezierPathProg.close()
                progressLayer.path = bezierPathProg.cgPath
                progressLayer.fillColor = UIColor.purple.cgColor
                oddsBarView.layer.addSublayer(progressLayer)
                
            }
        }
    }
    

    
    @IBAction func entity1Clicked(_ sender: Any) {
        entity1Button.backgroundColor = hexStringToUIColor(hex: "7D1A7D")
        entity2Button.backgroundColor = hexStringToUIColor(hex: "555555")
        decisionLabel.text = "You think " +  title1
        
        teamSelected = 1
        selectionMade = true
        updateSubmit()

    }
    
    @IBAction func entity2Clicked(_ sender: Any) {
        
        entity2Button.backgroundColor = hexStringToUIColor(hex: "7D1A7D")
        entity1Button.backgroundColor = hexStringToUIColor(hex: "555555")
        decisionLabel.text = "You think " +  title2
        
        teamSelected = 2
        selectionMade = true
        updateSubmit()

    }
    
    
    
    @IBAction func submitForecast(_ sender: Any) {
        if Reachability.isInternetAvailable() {
            let betSize = Int(round(sliderValue.value/5))*5
            if (DatabaseService.makePick(id: String(userId), betSize: betSize, pickId: teamSelected, event: event!, id1: Int(entity1id!), id2: Int(entity2id!))) {
                
                SessionState.coreDataManager.persistentContainer.viewContext.perform {
                    self.event?.pickedOutcomeId = Int32(self.teamSelected)
                    self.event?.betSize = Int32(betSize)
                    self.updateCoins(coinWager: betSize)
                    
                    // Track bet making
                    // AnalyticsParameterValue is the time until experiation in seconds
                    // pickedOutcomeId is the side that the user bet on
                    Analytics.logEvent("betMade", parameters: [AnalyticsParameterItemCategory: self.event?.categoryName! as Any, AnalyticsParameterItemID: self.event?.eventTitle! as Any, AnalyticsParameterContentType: "detail-bet", AnalyticsParameterQuantity: self.event?.expiresIn as Any, AnalyticsParameterValue: self.event?.betSize as Any, AnalyticsParameterIndex: self.event?.pickedOutcomeId as Any])
                    
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
        } else {
            informUserNoInternet()
        }
        
        
        
    }
    
    private func updateCoins(coinWager: Int) {
        do {
            if let user = try SessionState.coreDataManager.persistentContainer.viewContext.existingObject(with: SessionState.userNSObjectId!) as? User {
                user.coins -= Int32(coinWager)
            }
        } catch let error {
            print("NSObject not found from id error: \(error)")
        }
    }
    
    @IBOutlet weak var sliderLabel: UILabel!
    
    private func setSubmitStatus(canSubmit: Bool) {
        if (canSubmit) {
            //sliderLabel.textColor = UIColor.white
            submitButton.isEnabled = true
            submitButton.setTitleColor(UIColor.white, for: .normal)
            submitButton.backgroundColor = UIColor.purple
        } else {
            //sliderLabel.textColor = UIColor.red
            submitButton.isEnabled = false
            submitButton.setTitleColor(AppTheme.lightGrey, for: .normal)
            submitButton.backgroundColor = UIColor.darkGray

            
        }
    }
    
    private func updateSubmit() {
        sliderLabel.text = "Confidence: " + String(bet) + "%"
        if selectionMade {
            setSubmitStatus(canSubmit: true)
            updateWinning()
        }
    }
    
    
    @IBAction func wagerSlider(_ sender: UISlider) {
        bet = Int(round(sender.value/5))*5
        updateSubmit()

    }
    
    private func updateWinning(){
        let outcome1 = event?.outcomes![0] as? Outcome
        let outcome2 = event?.outcomes![1] as? Outcome
        
        if teamSelected == 1{
            scoreOutcome1Label.textColor = UIColor.purple
            scoreOutcome2Label.textColor = UIColor.gray
            scoreOutcome1Label.text = "You stand to gain " + String(Int((event?.maxOutcome1Correct)! * Double(bet)/100)) + " Reputation"
            scoreOutcome2Label.text = "You stand to lose " + String(Int((event?.maxOutcome2Correct)! * Double(bet)/100)) + " Reputation"
        } else {
            scoreOutcome2Label.textColor = UIColor.purple
            scoreOutcome1Label.textColor = UIColor.gray
            scoreOutcome2Label.text = "You stand to gain " + String(Int((event?.maxOutcome2Correct)! * Double(bet)/100)) + " Reputation"
            scoreOutcome1Label.text = "You stand to lose " + String(Int((event?.maxOutcome1Correct)! * Double(bet)/100)) + " Reputation"
        }
        
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
        self.oddsBarView.backgroundColor = StoryboardConstants.backgroundColor1
        self.scoreOutcome1Label.textColor = StoryboardConstants.backgroundColor1
        self.scoreOutcome2Label.textColor = StoryboardConstants.backgroundColor1
        self.submitButton.layer.cornerRadius = 5
        setSubmitStatus(canSubmit: false)

        
        
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


            let poolTotal = Double((outcome1?.pool)! + (outcome2?.pool)!)
            if (poolTotal > 0) {
                var percent1 = Double((outcome1?.pool)!)/poolTotal * 100
                var percent2 = Double((outcome2?.pool)!)/poolTotal * 100
                percent1.round()
                percent2.round()

                poolSize.text = "\(Int(percent1))% \(title1) - \(Int(percent2))% \(title2)"
            } else {
                poolSize.text = "50% \(title1) - 50% \(title2)"
            }
            
            eventTitle.text = event?.eventTitle

        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func informUserNoInternet() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "No internet", message: "Make sure your device is connected to the internet and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
