//
//  TestData.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

struct TestData {
    
    static var currentUser: [String: Any] = [
        "query": "users",
        "results_count": 1,
        "page": 1,
        "results": [
            [
                "BIRTHDATE": "1996-02-10",
                "COLLEGE": "STANFORD",
                "EMAIL": "cjamdolese@gmail.com",
                "FIRSTNAME": "Colin",
                "ID": 1,
                "LASTNAME": "Dolese",
                "PASSWORD": "colin_password",
                "PHONE": "4062746887",
                "COINS": 100,
                "OPEN_EVENTS": [
                    [
                        "CHOSEN_TEAM" : "Duke",
                        "OPPOSING_TEAM" : "Stanford",
                        "COIN_DEPOSIT" : 50,
                        "ODDS_CHOSEN_TEAM" : 95,
                        "ODDS_OPPOSING_TEAM" : 5
                        
                    ],
                    [
                        "CHOSEN_TEAM" : "USC",
                        "OPPOSING_TEAM" : "UM",
                        "COIN_DEPOSIT" : 25,
                        "ODDS_CHOSEN_TEAM" : 60,
                        "ODDS_OPPOSING_TEAM" : 40
                        
                    ]
                ]
            ]
        ]
    ]
    
    
    static var users: [String: Any] = [
        "query": "users",
        "results_count": 2,
        "page": 1,
        "results": [
            [
                "BIRTHDATE": "1996-02-10",
                "COLLEGE": "STANFORD",
                "EMAIL": "cjamdolese@gmail.com",
                "FIRSTNAME": "Colin",
                "ID": 1,
                "LASTNAME": "Dolese",
                "PASSWORD": "colin_password",
                "PHONE": "4062746887",
                "COINS": 100,
                "OPEN_EVENTS": [
                    [
                        "CHOSEN_TEAM" : "Duke",
                        "OPPOSING_TEAM" : "Stanford",
                        "COIN_DEPOSIT" : 50,
                        "ODDS_CHOSEN_TEAM" : 95,
                        "ODDS_OPPOSING_TEAM" : 5

                    ],
                    [
                        "CHOSEN_TEAM" : "USC",
                        "OPPOSING_TEAM" : "UM",
                        "COIN_DEPOSIT" : 25,
                        "ODDS_CHOSEN_TEAM" : 60,
                        "ODDS_OPPOSING_TEAM" : 40
                        
                    ]
                ]
            ],
            [
                "BIRTHDATE": "1996-08-23",
                "COLLEGE": "Duke",
                "EMAIL": "test@email.com",
                "FIRSTNAME": "John",
                "ID": 2,
                "LASTNAME": "Doe",
                "PASSWORD": "john_password",
                "PHONE": "1111111111",
                "COINS": 100,
                "OPEN_EVENTS": [
                    [
                        "CHOSEN_TEAM" : "Duke",
                        "OPPOSING_TEAM" : "Stanford",
                        "COIN_DEPOSIT" : 50,
                        "ODDS_CHOSEN_TEAM" : 95,
                        "ODDS_OPPOSING_TEAM" : 5
                        
                    ],
                    [
                        "CHOSEN_TEAM" : "USC",
                        "OPPOSING_TEAM" : "UM",
                        "COIN_DEPOSIT" : 25,
                        "ODDS_CHOSEN_TEAM" : 60,
                        "ODDS_OPPOSING_TEAM" : 40
                        
                    ]
                ]
            ]
        ]
    ]

    static var events: [String: Any] = [
        "query": "events",
        "results_count": 2,
        "page": 1,
        "results":[
            [
                "ENDDATE": "2018-03-10",
                "TEAM1": "Duke",
                "TEAM2": "Stanford",
                "ODDSTEAM1": 95,
                "ODDSTEAM2": 5
            ],
            [
        
                "ENDDATE": "2018-03-12",
                "TEAM1": "USC",
                "TEAM2": "UM",
                "ODDSTEAM1": 60,
                "ODDSTEAM2": 40
            ]
        ]
    ]

}

