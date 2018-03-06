//
//  Server.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation


class DatabaseService {
    
    let urlComponents: URLComponents // base URL components of the web service
    let session: URLSession // shared session for interacting with the web service
    
    init(urlComponents: URLComponents, session: URLSession) {
        self.urlComponents = urlComponents
        self.session = session
    }
    
//    static func fetchUsers(matching query: String, completion: ([User]) -> Void) {
//
//        var searchURLComponents = urlComponents
//        searchURLComponents.path = "/search"
//        searchURLComponents.queryItems = [URLQueryItem(name: "q", value: query)]
//        let searchURL = searchURLComponents.url!
//
//        session.dataTask(url: searchURL, completion: { (_, _, data, _)
//            var users: [User] = []
//
//            if let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                for case let result in json["results"] {
//                    if let User = User(json: result) {
//                        users.append(user)
//                    }
//                }
//            }
//
//            completion(users)
//        }).resume()
//    }
    
    
    // TEST FUNCTIONS ONLY
    static func fetchTestUsers(json: [String: Any]) -> [User] {
        var users: [User] = []
        if let results = json["results"] as? [[String: Any]] {
            for result in results {
                if let user = User(json: result) {
                    users.append(user)
                }
                
            }
        }
        return users
    }
    
    static func fetchTestEvents(json: [String: Any]) -> [Event] {
        var events: [Event] = []
        if let results = json["results"] as? [[String: Any]] {
            for result in results {
                if let event = Event(json: result) {
                    events.append(event)
                }
            }
        }
        return events
    }
    
    static func fetchCurrentUser(json: [String: Any]) -> User {
        var users: [User] = []
        if let results = json["results"] as? [[String: Any]] {
            for result in results {
                if let user = User(json: result) {
                    users.append(user)
                }
            }
        }
        return users[0]
    }

}
