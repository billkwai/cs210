//
//  CoreDataContextManager.swift
//  LynxApp
//
//  Created by Colin James Dolese on 4/27/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    var persistentContainer : NSPersistentContainer
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        self.persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    
}
