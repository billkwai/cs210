//
//  AutoLoginViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 4/26/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import FacebookCore

class AutoLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let accessToken = AccessToken.current {
            self.performSegue(withIdentifier: StoryboardConstants.LoginToHome, sender: nil)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
