//
//  Event.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

class Event {
    
    let endDate: String
    let team1: String
    let team2: String
    let oddsTeam1: Int
    let oddsTeam2: Int
    
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init?(json: [String: Any]) {
        guard let endDateJSON = json["ENDDATE"] as? String,
            let team1JSON = json["TEAM1"] as? String,
            let team2JSON = json["TEAM2"] as? String,
            let oddsTeam1JSON = json["ODDSTEAM1"] as? Int,
            let oddsTeam2JSON = json["ODDSTEAM2"] as? Int
            else {
                return nil
            }
        
        // Initialize properties
        self.endDate = endDateJSON
        self.team1 = team1JSON
        self.team2 = team2JSON
        self.oddsTeam1 = oddsTeam1JSON
        self.oddsTeam2 = oddsTeam2JSON
        


    }
    
    
}
