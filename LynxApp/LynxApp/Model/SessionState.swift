//
//  SessionStateData.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation
import CoreData

struct SessionState {
    
   static var currentUser: User?
    
    //static var persistentContainer: NSPersistentContainer?
   //static var managedContext: NSManagedObjectContext?
   static let coreDataManager = CoreDataManager(modelName: "DataModel")

   static func saveCoreData() {
        coreDataManager.managedObjectContext.perform {
            do {
                if  SessionState.coreDataManager.managedObjectContext.hasChanges {
                    try SessionState.coreDataManager.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
    
    
}
