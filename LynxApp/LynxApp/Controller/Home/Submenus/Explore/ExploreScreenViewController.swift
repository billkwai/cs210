//
//  ExploreScreenViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 5/9/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class ExploreScreenViewController: UIViewController {
    @IBOutlet weak var rightMenuLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
        
        let tapRight = UITapGestureRecognizer(target: self, action: #selector(self.tapRightMenu))
        rightMenuLabel.isUserInteractionEnabled = true
        rightMenuLabel.addGestureRecognizer(tapRight)

    }
    
    @objc func tapRightMenu() {
        if let pageController = self.parent?.parent as? HomePageViewController {
            pageController.presentRightView()
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
