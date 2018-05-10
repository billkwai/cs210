//
//  DatabaseService.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation
import CoreData
import FacebookCore
import FacebookLogin


class DatabaseService {
    
    static let baseUrl = "http://129.150.222.55:8080"
    static var apiKey = ""
    
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

    // Login/Registration Requests
    
    // fields must be a string of comma-seperated field names
    static func getFacebookFields(accessToken: AccessToken, fields: String, completion: @escaping([String: Any]) -> ()) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields":fields], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: GraphAPIVersion.defaultVersion )) { httpResponse, result in
            switch result {
            case .success(let response):
                completion(response.dictionaryValue!)
            case .failed( _):
                print(result)
                print("failed")
            }
        }
        connection.start()
    }
    
    
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
                    if let key = json["api_key"] as! String? {
                        apiKey = key
                        KeychainWrapper.standard.set(apiKey, forKey: ModelConstants.keychainApiKey)
                    }
                    return true
                }
            }
        }
        return false
        
    }
    
    
    // TO DO - shouldn't be passing the actual user, pass user id!!!
    
    static func getUser(id: String) {
        let privateContext = SessionState.coreDataManager.persistentContainer.newBackgroundContext()

        let response = Just.get(baseUrl + requests.userpath + "/" + id, headers:["Authentication":"Basic " + apiKey])
        if let json = response.json as? [String: Any] {
            updateUser(json: json, privateContext: privateContext)
        }
    }
    
    static func createUser(firstName: String, lastName: String, email: String) -> Bool {
        
        let response = Just.post(baseUrl + requests.userpath, json:["firstName": firstName, "lastName": lastName,"username": email, "email": email, "phone": "", "birthDate": "", "password": ""])
        if let json = response.json as? [String: Any] {
            if let status = json["status"] as! Int? {
                
                if (status == result_status.POST_SUCCESSFUL) {
                    return true
                }
                else {
                    debugPrint(json["message"] as! String)
                }
            }
            
        }
        
        return false
    }
    
    
    // Event Related Requests
    
    static func updateEventData(id: String) {
        let privateContext = SessionState.coreDataManager.persistentContainer.newBackgroundContext()
        getActiveEvents(id: id, privateContext: privateContext)
        getUserEvents(id: id, privateContext: privateContext)

    }
    
    
    
    private static func getUserEvents(id: String, privateContext: NSManagedObjectContext) {
        Just.get(baseUrl + requests.userpath + "/" + id + "/picks", headers:["Authentication":"Basic " + apiKey]) { (response) in
            if let json = response.json as? [[String: Any]] {
                for entry in json {
                    updateEvent(json: entry, privateContext: privateContext)
                }
            }
            
        }
    }
    
    private static func getActiveEvents(id: String, privateContext: NSManagedObjectContext) {
        Just.get(baseUrl + requests.userpath + "/" + id + "/events/current", headers:["Authentication":"Basic " + apiKey]) { (response) in
            if let json = response.json as? [[String: Any]] {
                for entry in json {
                    updateEvent(json: entry, privateContext: privateContext)
                }
            }

        }
        
    }
    
    
    
    static func makePick(id: String, betSize: Int, pickId: Int, event: Event,
                         id1: Int, id2: Int) -> Bool {
        
        let outcome1 = event.outcomes![0] as! Outcome
        let outcome2 = event.outcomes![1] as! Outcome
        let response = Just.post(baseUrl + requests.userpath + "/" + id + "/picks", json:["entity1_pool":outcome1.pool, "entity2_pool":outcome2.pool,"bet_size":betSize, "event_id": event.id, "picked_entity": pickId, "entity1_id": id1, "entity2_id": id2], headers:["Authentication":"Basic " + apiKey])
        
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
    
    static func updateSocialData() {
        let privateContext = SessionState.coreDataManager.persistentContainer.newBackgroundContext()
        getLeaderboard(privateContext: privateContext)

        
    }
    
    private static func getLeaderboard(privateContext: NSManagedObjectContext) {
        
        Just.get(baseUrl + requests.userpath + "/leaderboard/all", headers:["Authentication":"Basic " + apiKey]) { (response) in
            if let json = response.json as? [[String: Any]] {
                for entry in json {
                    let _ = updateUser(json: entry, privateContext: privateContext)
                }
            }
            
        }
        
    }
    
    
    // CoreData save/update/access
    
    
    private static func updateEvent(json: [String: Any], privateContext: NSManagedObjectContext) {
    
        let id = json["event_id"] as? Int
        if id == nil {
            // error
            return
        }
        
        let eventFetch = NSFetchRequest<Event>(entityName: "Event")
        eventFetch.predicate = NSPredicate(format: "id == %ld", id!)
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: eventFetch) {
            asyncResult in
            guard let result = asyncResult.finalResult else { return }
            DispatchQueue.main.async {
                let events: [Event] = result.lazy
                    .flatMap { $0.objectID } // Retrives all the objectsID
                    .compactMap { SessionState.coreDataManager.persistentContainer.viewContext.object(with: $0) as? Event }
                
                if events.count > 0 {
                    self.updateEventFields(event: events.first!, json: json, privateContext: privateContext)

                } else {
                    self.addEventFields(id: id!, json: json, privateContext: privateContext)
                }
                do {
                    // Saves the entry updated
                    if privateContext.hasChanges {
                        try privateContext.save()
                        
                        // Performs a task in the main queue and wait until this tasks finishes
                        SessionState.coreDataManager.persistentContainer.viewContext.performAndWait {
                            do {
                                // Saves the data from the child to the main context to be stored properly
                                try SessionState.coreDataManager.persistentContainer.viewContext.save()
                            } catch {
                                fatalError("Failure to save context: \(error)")
                            }
                        }
                    }
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
            }
            
        }
        do {
            // Executes `asynchronousFetchRequest`
            // crashes here after being active for long enough!
            try privateContext.execute(asyncFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest error: \(error)")
        }
    
    }
    
    static private func updateEventFields(event: Event, json: [String: Any], privateContext: NSManagedObjectContext) {
        let outcome1 = event.outcomes![0] as! Outcome
        let outcome2 = event.outcomes![1] as! Outcome
        
        if let expiresIn = json["expires_in"] as? Int32 {
            if event.expiresIn != expiresIn {
                event.expiresIn = expiresIn
            }
        }
        if let eventActive = json["event_active"] as? Int32 {
            if event.eventActive != eventActive {
                event.eventActive = eventActive
            }
        }
        if let pickingActive = json["picking_active"] as? Int32 {
            if pickingActive != pickingActive {
                event.pickingActive = pickingActive
            }
        }
        if let pickTimestamp = json["pick_timestamp"] as? String {
            if pickTimestamp != pickTimestamp {
                event.pickTimestamp = pickTimestamp
            }
        }
        if let betSize = json["bet_size"] as? Int32 {
            if event.betSize != betSize {
                event.betSize = betSize
            }
        }
        if let pickedOutcome = json["picked_entity"] as? Int32 {
            if event.pickedOutcomeId != pickedOutcome {
                event.pickedOutcomeId = pickedOutcome
            }
        }
        if let correctPayout = json["correct_payout"] as? Double {
            if event.correctPayout != correctPayout {
                event.correctPayout = correctPayout
            }
        }
        
        if let poolOutcome1 = json["entity1_pool"] as? Int32 {
            if outcome1.pool != poolOutcome1 {
                outcome1.pool = poolOutcome1
            }
        }
        
        if let poolOutcome2 = json["entity2_pool"] as? Int32 {
            if outcome2.pool != poolOutcome2 {
                outcome2.pool = poolOutcome2
            }
        }
    }

    static private func addEventFields(id: Int, json: [String: Any], privateContext: NSManagedObjectContext) {
        let event = Event(context: privateContext)
        let outcome1 = Outcome(context: privateContext)
        let outcome2 = Outcome(context: privateContext)
        
        // Add all static attributes/relationships
        event.id = Int32(id)
        if let eventTitle = json["event_title"] as? String {
            event.eventTitle = eventTitle
        }
        if let categoryName = json["category_name"] as? String {
            event.categoryName = categoryName
        }
        if let eventTime = json["event_time"] as? String {
            event.eventTime = eventTime
        }
        event.addToOutcomes(outcome1)
        event.addToOutcomes(outcome2)
        
        if let titleOutcome1 = json["entity1_name"] as? String {
            outcome1.title = titleOutcome1
        }
        if let idOutcome1 = json["entity1_id"] as? Int32 {
            outcome1.id = idOutcome1
        }
        outcome1.event = event
        
        if let titleOutcome2 = json["entity2_name"] as? String {
            outcome2.title = titleOutcome2
        }
        if let idOutcome2 = json["entity2_id"] as? Int32 {
            outcome2.id = idOutcome2
        }
        outcome2.event = event
        
        if let expiresIn = json["expires_in"] as? Int32 {
            event.expiresIn = expiresIn
        }
        if let eventActive = json["event_active"] as? Int32 {
            event.eventActive = eventActive
        }
        if let pickingActive = json["picking_active"] as? Int32 {
            event.pickingActive = pickingActive
        }
        if let pickTimestamp = json["pick_timestamp"] as? String {
            event.pickTimestamp = pickTimestamp
        }
        if let betSize = json["bet_size"] as? Int32 {
            event.betSize = betSize
        }
        if let pickedOutcome = json["picked_entity"] as? Int32 {
            event.pickedOutcomeId = pickedOutcome
        }
        if let correctPayout = json["correct_payout"] as? Double {
            event.correctPayout = correctPayout
        }
        
        if let poolOutcome1 = json["entity1_pool"] as? Int32 {
            outcome1.pool = poolOutcome1
        }
        
        if let poolOutcome2 = json["entity2_pool"] as? Int32 {
            outcome2.pool = poolOutcome2
        }
    }
    
    private static func updateUser(json: [String: Any], privateContext: NSManagedObjectContext) {

        let id = json["id"] as? Int32
        if id == nil {
            return
        }
        
        let userFetch = NSFetchRequest<User>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "id == %ld",id!)
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: userFetch) {
            asyncResult in
            guard let result = asyncResult.finalResult else { return }
            DispatchQueue.main.async {
                let users: [User] = result.lazy
                    .flatMap { $0.objectID } // Retrives all the objectsID
                    .compactMap { SessionState.coreDataManager.persistentContainer.viewContext.object(with: $0) as? User }
                
                if users.count > 0 {
                    self.updateUserFields(user: users.first!, json: json, privateContext: privateContext)
                    
                } else {
                    self.addUserFields(id: id!, json: json, privateContext: privateContext)
                }
                do {
                    // Saves the entry updated
                    if privateContext.hasChanges {
                        try privateContext.save()
                        
                        // Performs a task in the main queue and wait until this tasks finishes
                        SessionState.coreDataManager.persistentContainer.viewContext.performAndWait {
                            do {
                                // Saves the data from the child to the main context to be stored properly
                                try SessionState.coreDataManager.persistentContainer.viewContext.save()
                            } catch {
                                fatalError("Failure to save context: \(error)")
                            }
                        }
                    }
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
            }
            
        }
        do {
            // Executes `asynchronousFetchRequest`
            // error also happening here
            try privateContext.execute(asyncFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest error: \(error)")
        }
    }
    
    private static func updateUserFields(user: User, json: [String: Any], privateContext: NSManagedObjectContext) {
        
        if let coins = json["coins"] as? Int32 {
            if user.coins != coins {
                user.coins = coins
            }
        }
        
    }
    
    private static func addUserFields(id: Int32, json: [String: Any], privateContext: NSManagedObjectContext) {
        let user = User(context: privateContext)
        if let birthdate = json["birthdate"] as? String {
            user.birthdate = birthdate
        }
        if let email = json["email"] as? String {
            user.email = email
        }
        if let username = json["username"] as? String {
            user.username = username
        }
        if let coins = json["coins"] as? Int32 {
            user.coins = coins
        }
        if let firstName = json["firstname"] as? String {
            user.firstName = firstName
        }
        if let lastName = json["lastname"] as? String {
            user.lastName = lastName
        }
        user.id = id
    
    }
    
    

}
