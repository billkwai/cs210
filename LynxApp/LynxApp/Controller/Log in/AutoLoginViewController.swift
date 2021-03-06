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


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let accessToken = AccessToken.current {
            SessionState.accessToken = accessToken
            toMenu()
        }
    }
    
    private func toMenu() {
        let vc = self.view?.window?.rootViewController
        let menuvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardConstants.MenuVC)
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFade
        menuvc.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: false, completion: nil)
        vc?.present(menuvc, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
