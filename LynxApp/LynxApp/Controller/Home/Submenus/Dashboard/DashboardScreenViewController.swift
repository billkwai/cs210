//
//  DashboardScreenViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 5/9/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class DashboardScreenViewController: UIViewController {
    @IBOutlet weak var leftScreenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(self.tapLeftMenu))
        leftScreenLabel.isUserInteractionEnabled = true
        leftScreenLabel.addGestureRecognizer(tapLeft)

        // Do any additional setup after loading the view.
    }
    
    @objc func tapLeftMenu() {
        if let pageController = self.parent?.parent as? HomePageViewController {
            pageController.presentLeftView()
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
