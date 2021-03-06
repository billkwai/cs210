//
//  EventCell.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/15/18.
//  Copyright © 2018 Zeeshan Khan. All rights reserved.
//

import UIKit

class ActiveEventCell: UITableViewCell {
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var oddsBarView: UIView!
    
    @IBOutlet weak var outcome1Label: UILabel!
    
    @IBOutlet weak var outcome2Label: UILabel!
    
    @IBOutlet weak var timeNumberLabel: UILabel!
    
    @IBOutlet weak var timeUnitLabel: UILabel!
    
    @IBOutlet weak var categoryImage: UIImageView!
        
    @IBOutlet weak var poolSizeLabel: UILabel!
    
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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor =  StoryboardConstants.backgroundColor1

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor =  StoryboardConstants.backgroundColor1
        self.oddsBarView.backgroundColor = StoryboardConstants.backgroundColor1


        // Configure the view for the selected state
    }
    
}
