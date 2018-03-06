//
//  User.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

struct OpenUserEvent {
    
    let chosenTeam: String
    let opposingTeam: String
    let oddsChosenTeam: Int
    let oddsOpposingTeam: Int
    let coinDeposit: Int
    
}

class User {

    let birthDate: String
    let college: String
    let email: String
    let phone: String
    let id: Int
    let firstName: String
    let lastName: String
    let password: String
    let coins: Int
    
    let openUserEvents: [OpenUserEvent]

    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }

    init?(json: [String: Any])  {
        guard let birthdateJSON = json["BIRTHDATE"] as? String,
            let collegeJSON = json["COLLEGE"] as? String,
            let emailJSON = json["EMAIL"] as? String,
            let firstNameJSON = json["FIRSTNAME"] as? String,
            let idJSON = json["ID"] as? Int,
            let lastNameJSON = json["LASTNAME"] as? String,
            let passwordJSON = json["PASSWORD"] as? String,
            let phoneJSON = json["PHONE"] as? String,
            let coinsJSON = json["COINS"] as? Int,
            let openEventsJSON = json["OPEN_EVENTS"] as? [[String: Any]]
        else {
            return nil
        }
        
        
        var openUserEventsJSON: [OpenUserEvent] = []
        for event in openEventsJSON {
            guard let chosenTeamJSON = event["CHOSEN_TEAM"] as? String,
                let opposingTeamJSON = event["OPPOSING_TEAM"] as? String,
                let oddsChosenTeamJSON = event["ODDS_CHOSEN_TEAM"] as? Int,
                let oddsOpposingTeamJSON = event["ODDS_OPPOSING_TEAM"] as? Int,
                let coinDepositJSON = event["COIN_DEPOSIT"] as? Int
            else {
                return nil
            }
            openUserEventsJSON.append(OpenUserEvent(chosenTeam: chosenTeamJSON, opposingTeam: opposingTeamJSON, oddsChosenTeam: oddsChosenTeamJSON, oddsOpposingTeam: oddsOpposingTeamJSON, coinDeposit: coinDepositJSON))
        }
        
        
        // Initialize properties
        self.birthDate = birthdateJSON
        self.college = collegeJSON
        self.email = emailJSON
        self.phone = phoneJSON
        self.id = idJSON
        self.firstName = firstNameJSON
        self.lastName = lastNameJSON
        self.password = passwordJSON
        self.coins = coinsJSON
        
        self.openUserEvents = openUserEventsJSON
    }


}



