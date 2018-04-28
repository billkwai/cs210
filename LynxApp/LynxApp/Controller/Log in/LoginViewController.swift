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
        addLoginButton()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addLoginButton() {
        // Add a custom login button to your app
        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = UIColor.darkGray
        loginButton.frame = CGRect(x:0, y:0, width:180, height:40);
        loginButton.center = CGPoint(x:view.center.x, y:view.center.y + 300);
        loginButton.setTitle("Login with Facebook", for: .normal)
        
        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(loginButton)
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
                
                self.attemptLogin(accessToken: accessToken)
                
                // if didn't allow needed permissions, abort
                
                
            }
        }
        
    }
    
    private func attemptLogin(accessToken: AccessToken) {
        DatabaseService.getFacebookFields(accessToken: accessToken, fields: "email,first_name, last_name", completion: { (values) -> Void in
            if let email = values["email"] as? String {
                if let id = DatabaseService.checkIfUserExists(name: email) {
                    SessionState.userId = id
                    DatabaseService.getUser(id: String(id))
                    let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                    if (saveUserId) {
                        DispatchQueue.main.async {
                            self.toMenu()
                        }
                    } else {
                        // TODO: report keychain error
                    }
                } else {
                    // save user to cloud database
                    if (DatabaseService.createUser(firstName: values["first_name"] as! String, lastName: values["last_name"] as! String, email: email)) {
                        
                        if let id = DatabaseService.checkIfUserExists(name: email) { // user created, now fetch info
                            SessionState.userId = id
                            DatabaseService.getUser(id: String(id))
                            let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                            if (saveUserId) {
                                DispatchQueue.main.async {
                                    self.toMenu()
                                }
                            } else {
                                // keychain error
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    private func toMenu() {
        let vc = self.view?.window?.rootViewController
        let ViewControllernew1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardConstants.MenuVC)
        self.dismiss(animated: false, completion: nil)
        vc?.present(ViewControllernew1, animated: true, completion: nil)
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


}
