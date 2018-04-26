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
    
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a custom login button to your app
        let myLoginButton = UIButton(type: .custom)
        myLoginButton.backgroundColor = UIColor.darkGray
        myLoginButton.frame = CGRect(x:0, y:0, width:180, height:40);
        myLoginButton.center = CGPoint(x:view.center.x, y:view.center.y + 300);
        myLoginButton.setTitle("Login with Facebook", for: .normal)
        
        // Handle clicks on the button
        myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(myLoginButton)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func verifyInput() -> Bool {
        if (emailInput.text == "") {
            informUserFieldEmpty()
            return false
        } else if (passwordInput.text == "") {
            informUserFieldEmpty()
            return false
        }
        return true
        
        
        
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                // TODO: check if needed permissions are satisfied and handle case where they are not
                
                if let accessToken = AccessToken.current {
                    DatabaseService.getFacebookFields(accessToken: accessToken, fields: "email,firstName, lastName", completion: { (values) -> Void in
                        if let email = values["email"] as? String {
                            if let id = DatabaseService.checkIfUserExists(name: email) {
                                if let user = DatabaseService.getUser(id: String(id)) {
                                    let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                                    if (saveUserId) {
                                        SessionState.currentUser = user
                                        self.performSegue(withIdentifier: StoryboardConstants.LoginToHome, sender: nil)
                                    } else {
                                        // TODO: report keychain error
                                    }
                                }
                            } else {
                                // save user to cloud database
                                //                                if (DatabaseService.createUser(firstName: firstNameInput.text!, lastName: lastNameInput.text!, username: usernameInput.text!, email: emailInput.text!, phone: Int(phoneNumberInput.text!)!, birthDate: birthDateInput.text!, password: passwordInput.text!)) {
                                //
                                //                                    if let id = DatabaseService.checkIfUserExists(name: emailInput.text!) { // user created, now fetch info
                                //
                                //                                        if let user = DatabaseService.getUser(id: String(id)) {
                                //                                            let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                                //                                            if (saveUserId) {
                                //                                                SessionState.currentUser = user
                                //                                                performSegue(withIdentifier: StoryboardConstants.RegistrationToHome, sender: nil)
                                //                                            } else {
                                //                                                // TODO: report keychain error
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                }
                            }
                        }
                        
                    })
                }
                
                // if didn't allow needed permissions, abort
                
                
            }
        }
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        if (verifyInput()) {
            
            if let id = DatabaseService.checkIfUserExists(name: emailInput.text!) {
                
                let correctPassword = DatabaseService.login(id: String(id), password: passwordInput.text!)
                
                if (correctPassword) {
                    
                    if let user = DatabaseService.getUser(id: String(id)) {
                        let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                        if (saveUserId) {
                            SessionState.currentUser = user
                            performSegue(withIdentifier: StoryboardConstants.LoginToHome, sender: nil)
                        } else {
                            // TODO: report keychain error
                        }
                        
                    }
                    
                } else {
                    
                   informUserInformationIncorrect()
                    
                }
                
            } else {
                informUserInformationIncorrect()
            }
            
        }
        
    }
    
    
    
    // MARK: - User Messages
    
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    private func informUserInformationIncorrect() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Email or password incorrect", message: "We couldn't find the information you entered.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
