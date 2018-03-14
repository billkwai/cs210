//
//  Server.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation


class DatabaseService {
    
    static let baseUrl = "https://wepybackend-stanfordlynx.uscom-central-1.oraclecloud.com"
    
    struct requests {
        static let userpath = "/players"
    }
    
    struct result_status {
        static let NO_INITIAL_COINS = 2500
        static let USERNAME_INVALID = -1
        static let USERNAME_VALID = 1
        static let PASSWORD_INCORRECT = -2
        static let PASSWORD_CORRECT = 1
        static let DB_EXCEPTION_THROWN = -3
        static let POST_SUCCESSFUL = 1
        static let POST_UNSUCCESSFUL = -1

    
    }
    
    
    let urlComponents: URLComponents // base URL components of the web service
    let session: URLSession // shared session for interacting with the web service
    
    init(urlComponents: URLComponents, session: URLSession) {
        self.urlComponents = urlComponents
        self.session = session
    }
    

    // Login/Registration Requests
    
    static func checkIfUserExists(name: String) -> Int? {
        
        let response = Just.post(baseUrl + requests.userpath + "/username_exists", json:["username":name])
        if let json = response.json as? [String: Any] {
            if let status = json["status"] as! Int? {
                
                if status == result_status.USERNAME_VALID {
                    return json["id"] as? Int
                }
            }
        }
        return nil
    }
    
    static func login(id: String, password: String) -> Bool {
        
        let response = Just.post(baseUrl + requests.userpath + "/" + id + "/login", json:["password":password])
        if let json = response.json as? [String: Any] {
            if let status = json["status"] as! Int? {
                
                if status == result_status.PASSWORD_CORRECT  {
                    return true
                }
            }
        }
        return false
        
    }
    
    static func getUser(id: String) -> User? {
        
        let response = Just.get(baseUrl + requests.userpath + "/" + id)
        if let json = response.json as? [String: Any] {
            if let user = User(json: json) {
                return user
            }
        }
        return nil
        
    }
    
    static func createUser(firstName: String, lastName: String, username: String, email: String, phone: Int, birthDate: String, password: String) -> Bool {
        
        let response = Just.post(baseUrl + requests.userpath, json:["firstName": firstName, "lastName": lastName,"username": username, "email": email, "phone": phone, "birthDate": birthDate, "password": password])
        if let json = response.json as? [String: Any] {
            if let status = json["status"] as! Int? {
                
                if (status == result_status.POST_SUCCESSFUL) {
                    return true
                    
                }
            }
            
        }
        
        return false
    }
    
    
    // Event Related Requests
    
    static func getUserEvents(id: String, completion: @escaping ([UserEvent]) -> ()) {
        Just.get(baseUrl + requests.userpath + "/" + id + "/picks") { (response) in
            if let json = response.json as? [[String: Any]] {
                var events: [UserEvent] = []
                for entry in json {
                    if let event = UserEvent(json: entry) {
                        events.append(event)
                    }
                }
                completion(events)
            }
            
        }
    }
    
    static func getActiveEvents(id: String, completion: @escaping ([ActiveEvent]) -> ()) {
        
        Just.get(baseUrl + requests.userpath + "/" + id + "/events/current") { (response) in
            if let json = response.json as? [[String: Any]] {
                var events: [ActiveEvent] = []
                for entry in json {
                    if let event = ActiveEvent(json: entry) {
                        events.append(event)
                    }
                }
                
                completion(events)
            }

        }
        
    }
    
    
    
    static func makePick(id: String, betSize: Int, pickId: Int, event: ActiveEvent,
                         id1: Int, id2: Int) -> Bool {
        
        let response = Just.post(baseUrl + requests.userpath + "/" + id + "/picks", json:["entity1_pool":event.poolEntity1, "entity2_pool":event.poolEntity2,"bet_size":betSize, "event_id": event.id, "picked_entity": pickId, "entity1_id": id1, "entity2_id": id2])
        
        if let json = response.json as? [String: Any] {
            if let status = json["status"] as! Int? {
                    
                if (status == result_status.POST_SUCCESSFUL) {
                    return true
                }
            }
                
        }
        return false
    }
    
    
    
    // Leaderboard Related Requests
    
    static func getLeaderboard(completion: @escaping ([User]) -> ()) {
        
        Just.get(baseUrl + requests.userpath + "/leaderboard/all") { (response) in
            if let json = response.json as? [[String: Any]] {
                var users: [User] = []
                for entry in json {
                    if let user = User(json: entry) {
                        users.append(user)
                    }
                }
                
                completion(users)
            }
            
        }
        
    }
    
    
    
    // TEST FUNCTIONS ONLY
//    static func fetchTestUsers(json: [String: Any]) -> [User] {
//        var users: [User] = []
//        if let results = json["results"] as? [[String: Any]] {
//            for result in results {
//                if let user = User(json: result) {
//                    users.append(user)
//                }
//
//            }
//        }
//        return users
//    }
//
//    static func fetchTestEvents(json: [String: Any]) -> [Event] {
//        var events: [Event] = []
//        if let results = json["results"] as? [[String: Any]] {
//            for result in results {
//                if let event = Event(json: result) {
//                    events.append(event)
//                }
//            }
//        }
//        return events
//    }
//
//    static func fetchTestCurrentUser(json: [String: Any]) -> User {
//        var users: [User] = []
//        if let results = json["results"] as? [[String: Any]] {
//            for result in results {
//                if let user = User(json: result) {
//                    users.append(user)
//                }
//            }
//        }
//        return users[0]
//    }

}
