//
//  RegistrationViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class RegistrationViewController: UITableViewController {
    
    
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var birthDateInput: UITextField!
    @IBOutlet weak var collegeInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    
    
    var currentUser: User?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func verifyInputs() -> Bool {
        // currently just checks each field was filled in
        // and that passwords match
        
        var valid = true
        
        if (firstNameInput.text == "") {
            valid = false
        } else if (lastNameInput.text == "") {
            valid = false
        } else if (birthDateInput.text == "") {
            valid = false
        } else if (collegeInput.text == "") {
            valid = false
        } else if (emailInput.text == "") {
            valid = false
        } else if (phoneNumberInput.text == "") {
            valid = false
        } else if (passwordInput.text == "") {
            valid = false
        } else if (confirmPasswordInput.text == "") {
            valid = false
        }
        
        if (!valid) {
            informUserFieldEmpty()
            return false
        }
        
        if (!isValidEmail(testStr: emailInput.text!)) {
            informUserEntryInvalid()
            return false
        }
        
        if (passwordInput.text != confirmPasswordInput.text) {
            informUserPasswordMismatch()
            return false
        }
        
        return true
    }

    @IBAction func registerPressed(_ sender: Any) {
        
        if (verifyInputs()) {
            
            // TODO - Make GET request to database to make sure
            // user does not already exist
            
            // TODO - Make POST request to database to create User
            
            SessionState.currentUser = DatabaseService.fetchCurrentUser(json: TestData.currentUser)
            performSegue(withIdentifier: StoryboardConstants.RegistrationToHome, sender: nil)

            
        }
        
    }
    
    // Mark - User Messages
    
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
    
    private func informUserPasswordMismatch() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Passwords Don't Match", message: "Please enter matching passwords.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardConstants.RegistrationToHome {
            let vc = segue.destination as? MenuViewController
            
            // do any prep
        }
    }
    

}
