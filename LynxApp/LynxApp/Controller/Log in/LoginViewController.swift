//
//  LoginViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var currentUser: User?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func verifyInput() -> Bool {
        // TODO - make verification more robust and informative
        if (emailInput.text == "") {
            informUserFieldEmpty()
            return false
        } else if (passwordInput.text == "") {
            informUserFieldEmpty()
            return false
        } else if (!isValidEmail(testStr: emailInput.text!)) {
            informUserEntryInvalid()
            return false
        }
        return true
        
        
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        if (verifyInput()) {
            
            // TODO - make GET request to database to determine if
            // user exists
            
            // TODO - If user exists, verify password matches
            
            SessionState.currentUser = DatabaseService.fetchCurrentUser(json: TestData.currentUser)
            performSegue(withIdentifier: StoryboardConstants.LoginToHome, sender: nil)

            
        }
        
    }
    
    
    
    // MARK: - User Messages
    
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    private func informUserFieldEmpty() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Empty Field", message: "Please enter your email and password.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func informUserEntryInvalid() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Invalid Entry", message: "Please enter a properly formatted email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardConstants.LoginToHome {
            let vc = segue.destination as? MenuViewController
            
            // Do any prep
        }
    }
    

}
