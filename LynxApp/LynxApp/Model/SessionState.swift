//
//  SessionStateData.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/17/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation
import CoreData
import FacebookCore

struct SessionState {
    
    static var currentUser: User?
    static var accessToken: AccessToken?
    static var userId: Int?
        
    static let coreDataManager = CoreDataManager(modelName: "DataModel")

    
    
}
