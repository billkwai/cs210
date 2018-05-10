//
//  SocialScreenViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 5/9/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class SocialScreenViewController: UIViewController {

    @IBOutlet weak var weeklyWinsLabel: UILabel!
    
    @IBOutlet weak var allWinsLabel: UILabel!
    
    @IBOutlet weak var accuracyLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
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
