//
//  AppDelegate.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import FacebookLogin
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        if let id = KeychainWrapper.standard.integer(forKey: ModelConstants.keychainUserId) {
            SessionState.userId = id
            if let apiKey = KeychainWrapper.standard.string(forKey: ModelConstants.keychainApiKey) {
                DatabaseService.apiKey = apiKey
            }
            
            if let user = fetchUser(id: id) {
                SessionState.userNSObjectId = user.objectID
                let autoLoginVC = mainStoryboard.instantiateViewController(withIdentifier: StoryboardConstants.AutoLoginVC) as! AutoLoginViewController
                self.window?.rootViewController = autoLoginVC
                

            } else {
                let loginPageVC = mainStoryboard.instantiateViewController(withIdentifier: StoryboardConstants.LoginPageVC) as! LoginPageViewController
                self.window?.rootViewController = loginPageVC

            }
        } else {
            let loginPageVC: LoginPageViewController = mainStoryboard.instantiateViewController(withIdentifier: StoryboardConstants.LoginPageVC) as! LoginPageViewController
            self.window?.rootViewController = loginPageVC

            
        }
        self.window?.makeKeyAndVisible()
        
        // configure Firebase Analytics
        FirebaseApp.configure()
        
        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    private func fetchUser(id: Int) -> User? {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "id == %ld",id)
        
        do {
            let fetchedUsers = try SessionState.coreDataManager.persistentContainer.viewContext.fetch (userFetch) as! [User]
            if fetchedUsers.count > 0 {
                let user = fetchedUsers.first!
                return user
            }
        } catch {
            // error
        }
        return nil
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

