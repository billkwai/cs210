//
//  UserEvent.swift
//  LynxApp
//
//  Created by Colin James Dolese on 3/10/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

class UserEvent {
    
    let id: Int
    
    let pickCorrect: Int?
    let pickTimestamp: String
    let pickedEntity: Int
    let correctPayout: Double
    let eventActive: Int
    let pickingActive: Int
    
    let entity1: String
    let poolEntity1: Int
    let idEntity1: Int
    
    let entity2: String
    let poolEntity2: Int
    let idEntity2: Int

    
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init?(json: [String: Any]) {
        guard let entity1JSON = json["entity1_name"] as? String,
            let entity2JSON = json["entity2_name"] as? String,
            let poolEntity1JSON = json["entity1_pool"] as? Int,
            let poolEntity2JSON = json["entity2_pool"] as? Int,
            let idEntity1JSON = json["entity1_id"] as? Int,
            let idEntity2JSON = json["entity2_id"] as? Int,
            let idJSON = json["event_id"] as? Int,
            let pickedEntityJSON = json["picked_entity1"] as? Int,
            let correctPayoutJSON = json["correct_payout"] as? Double,
            let eventActiveJSON = json["event_active"] as? Int,
            let pickTimestampJSON = json["pick_timestamp"] as? String,
            let pickingActiveJSON = json["picking_active"] as? Int
        
            else {
                return nil
        }
        
        if let resultJSON = json["pick_correct"] as? Int {
            self.pickCorrect = resultJSON
        } else {
            self.pickCorrect = nil
        }
        
        // Initialize properties
        self.id = idJSON
        self.entity1 = entity1JSON
        self.entity2 = entity2JSON
        self.poolEntity1 = poolEntity1JSON
        self.poolEntity2 = poolEntity2JSON
        self.idEntity1 = idEntity1JSON
        self.idEntity2 = idEntity2JSON
        self.pickedEntity = pickedEntityJSON
        self.correctPayout = correctPayoutJSON
        self.eventActive = eventActiveJSON
        self.pickTimestamp = pickTimestampJSON
        self.pickingActive = pickingActiveJSON
        
        
    }
    
    
}
