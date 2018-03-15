//
//  User.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation


class User {

    let birthDate: String
    let email: String
    let username: String
    
    let id: Int
    let coins: Int
    
    //let openUserEvents: [OpenUserEvent]

    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }

    init?(json: [String: Any])  {
        guard let birthdateJSON = json["birthdate"] as? String,
            let emailJSON = json["email"] as? String,
            let usernameJSON = json["username"] as? String,
            let idJSON = json["id"] as? Int,
            let coinsJSON = json["coins"] as? Int
        else {
            return nil
        }
        
        
//        var openUserEventsJSON: [OpenUserEvent] = []
//        for event in openEventsJSON {
//            guard let chosenTeamJSON = event["CHOSEN_TEAM"] as? String,
//                let opposingTeamJSON = event["OPPOSING_TEAM"] as? String,
//                let oddsChosenTeamJSON = event["ODDS_CHOSEN_TEAM"] as? Int,
//                let oddsOpposingTeamJSON = event["ODDS_OPPOSING_TEAM"] as? Int,
//                let coinDepositJSON = event["COIN_DEPOSIT"] as? Int
//            else {
//                return nil
//            }
//            openUserEventsJSON.append(OpenUserEvent(chosenTeam: chosenTeamJSON, opposingTeam: opposingTeamJSON, oddsChosenTeam: oddsChosenTeamJSON, oddsOpposingTeam: oddsOpposingTeamJSON, coinDeposit: coinDepositJSON))
//        }
        
        
        // Initialize properties
        self.birthDate = birthdateJSON
        self.email = emailJSON
        self.id = idJSON
        self.coins = coinsJSON
        self.username = usernameJSON
        
        //self.openUserEvents = openUserEventsJSON
    }


}



