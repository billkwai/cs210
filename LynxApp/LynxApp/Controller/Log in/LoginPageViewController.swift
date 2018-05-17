//
//  LoginPageViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 4/27/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAnalytics

class LoginPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var pageControl = UIPageControl()
    
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: StoryboardConstants.LoginVC1), self.newVc(viewController: StoryboardConstants.LoginVC2), self.newVc(viewController: StoryboardConstants.LoginVC3), self.newVc(viewController: StoryboardConstants.LoginVC4), self.newVc(viewController: StoryboardConstants.LoginVC5)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
        addLoginButton()
        
        // Do any additional setup after loading the view.
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.view.addSubview(pageControl)
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    // MARK: Delegate methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
             return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
           // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    private func addLoginButton() {
        // Add a custom login button to your app
        let loginButton = UIButton(type: .custom)
        //        loginButton.backgroundColor = UIColor.darkGray
        loginButton.frame = CGRect(x:0, y:0, width:200, height:40);
        // Added our own Facebook Login image - Basel
        let btnImage = UIImage(named: "fb-button")
        loginButton.setImage(btnImage, for: UIControlState.normal)
        loginButton.center = CGPoint(x:view.center.x, y:view.center.y + 200);
        //        loginButton.setTitle("Login with Facebook", for: .normal)
        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view

        view.addSubview(loginButton)
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
                // TODO: user_friends permission not being registered for some reason
                
                // Track if user attempted to login
                Analytics.logEvent("loginAttempted", parameters: nil)
                
                if grantedPermissions.contains("public_profile") && grantedPermissions.contains("email") {
                    self.attemptLogin(accessToken: accessToken)
                } else {
                    self.informUserPermissionsNeeded()
                }

                
            }
        }
    }
    
    
    
    private func attemptLogin(accessToken: AccessToken) {
        DatabaseService.getFacebookFields(accessToken: accessToken, fields: "email,first_name, last_name", completion: { (values) -> Void in
            if let email = values["email"] as? String {
                if let id = DatabaseService.checkIfUserExists(name: email) {
                    self.performLogin(id: id)
                } else {
                    // save user to cloud database
                    if (DatabaseService.createUser(firstName: values["first_name"] as! String, lastName: values["last_name"] as! String, email: email)) {
                        
                        // Track user signups
                        // currently only includes Facebook signups
                        Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterSignUpMethod: "facebook"])
                        
                        if let id = DatabaseService.checkIfUserExists(name: email) { // user created, now fetch info
                            self.performLogin(id: id)
                        }
                    }
                }
            }
            
        })
    }
    
    private func performLogin(id: Int) {
        SessionState.userId = id
        
        DatabaseService.getUser(id: String(id), completion: { successGetUser in
            
            if successGetUser {
                let saveUserId = KeychainWrapper.standard.set(id, forKey: ModelConstants.keychainUserId)
                if (saveUserId) {
                    DatabaseService.updateUserEventData(id: String(SessionState.userId!), completion: { successGetUserEvents in
                        if successGetUserEvents {
                            DatabaseService.updateActiveEventData(id: String(SessionState.userId!), completion: { successGetActiveEvents in
                                if successGetActiveEvents {
                                    // NOT CORRECTLY WAITING!
                                    DatabaseService.updateSocialData(completion: { successGetSocialData in
                                        if successGetSocialData {
                                            
                                            // Track successful login
                                            Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
                                            
                                            DispatchQueue.main.async {
                                                self.toMenu()
                                            }
                                        }
                                    })
                                }
                            })
                        }
                    })
                } else {
                    // TODO: report keychain error
                }
            }
            
        })
    }
    
    private func toMenu() {
        let vc = self.view?.window?.rootViewController
        let menuvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardConstants.MenuVC)
        
        // add simple login animation
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        vc?.present(menuvc, animated: false, completion: nil)
    }
    
    
    private func informUserPermissionsNeeded() {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Permissions not Given", message: "To make foresight's social predictions fun and effective, we require permissions to log in.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
