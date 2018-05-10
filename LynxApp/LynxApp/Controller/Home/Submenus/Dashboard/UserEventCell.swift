//
//  UserEventCell.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class UserEventCell: UITableViewCell {
        
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var timeNumberLabel: UILabel!
    @IBOutlet weak var oddsBarView: UIView!
    @IBOutlet weak var timeUnitLabel: UILabel!
    @IBOutlet weak var outcome1Label: UILabel!
    @IBOutlet weak var outcome2Label: UILabel!
    @IBOutlet weak var wagerLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    var drawn: Bool = false
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor =  StoryboardConstants.backgroundColor1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
