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

class LoginPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var pageControl = UIPageControl()
    
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: StoryboardConstants.LoginVC), self.newVc(viewController: "sampleLoginVC")]
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
        
        // Do any additional setup after loading the view.
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
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
            // return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            return nil
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
    
    
    public func loginClicked() {
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
        let menuvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardConstants.MenuVC)
        self.dismiss(animated: false, completion: nil)
        vc?.present(menuvc, animated: true, completion: nil)
    }
}
