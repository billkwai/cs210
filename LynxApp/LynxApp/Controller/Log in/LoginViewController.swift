//
//  LoginViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLoginButton()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addLoginButton() {
        // Add a custom login button to your app
        let loginButton = UIButton(type: .custom)
//        loginButton.backgroundColor = UIColor.darkGray
        loginButton.frame = CGRect(x:0, y:0, width:200, height:40);
        // Added our own Facebook Login image - Basel
        let btnImage = UIImage(named: "fb-button")
        loginButton.setImage(btnImage, for: UIControlState.normal)
        loginButton.center = CGPoint(x:view.center.x, y:view.center.y + 250);
//        loginButton.setTitle("Login with Facebook", for: .normal)
        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(loginButton)
    }
    

    @objc func loginButtonClicked() {
        if let loginpageVC = self.parent as? LoginPageViewController {
            loginpageVC.loginClicked()
        }
        
    }

}
