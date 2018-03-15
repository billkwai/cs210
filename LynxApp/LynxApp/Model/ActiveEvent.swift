//
//  ActiveEvent.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

class ActiveEvent {
    
    let id: Int
    let eventTime: String
    let eventTitle: String
    let expiresIn: Int
    
    let entity1: String
    let poolEntity1: Int
    let idEntity1: Int

    let entity2: String
    let poolEntity2: Int
    let idEntity2: Int
    
    let categoryName: String
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init?(json: [String: Any]) {
        guard let eventTimeJSON = json["event_time"] as? String,
            let entity1JSON = json["entity1_name"] as? String,
            let entity2JSON = json["entity2_name"] as? String,
            let poolEntity1JSON = json["entity1_pool"] as? Int,
            let poolEntity2JSON = json["entity2_pool"] as? Int,
            let idEntity1JSON = json["entity1_id"] as? Int,
            let idEntity2JSON = json["entity2_id"] as? Int,
            let idJSON = json["event_id"] as? Int,
            let titleEventJSON = json["event_title"] as? String,
            let categoryNameJSON = json["category_name"] as? String,
            let expiresInJSON = json["expires_in"] as? Int
            
            else {
                return nil
            }
        
        // Initialize properties
        self.eventTime = eventTimeJSON
        self.entity1 = entity1JSON
        self.entity2 = entity2JSON
        self.poolEntity1 = poolEntity1JSON
        self.poolEntity2 = poolEntity2JSON
        self.idEntity1 = idEntity1JSON
        self.idEntity2 = idEntity2JSON
        self.id = idJSON
        self.eventTitle = titleEventJSON
        self.categoryName = categoryNameJSON
        self.expiresIn = expiresInJSON
        


    }
    
    
}
