//
//  UserEvent.swift
//  LynxApp
//
//  Created by Colin James Dolese on 3/10/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

class UserEvent {
    
    let eventTime: String
    let id: Int
    
    let entity1: String
    let poolEntity1: Int
    let idEntity1: Int
    let pickEntity1 : String
    
    let entity2: String
    let poolEntity2: Int
    let idEntity2: Int
    let pickEntity2 : String

    
    
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
            let pickEntity1JSON = json["picked_entity1"] as? String,
            let pickEntity2JSON = json["picked_entity2"] as? String
        
            else {
                return nil
        }
        
        // Initialize properties
        self.id = idJSON
        self.eventTime = eventTimeJSON
        self.entity1 = entity1JSON
        self.entity2 = entity2JSON
        self.poolEntity1 = poolEntity1JSON
        self.poolEntity2 = poolEntity2JSON
        self.idEntity1 = idEntity1JSON
        self.idEntity2 = idEntity2JSON
        self.pickEntity1 = pickEntity1JSON
        self.pickEntity2 = pickEntity2JSON
        

        
        
    }
    
    
}
