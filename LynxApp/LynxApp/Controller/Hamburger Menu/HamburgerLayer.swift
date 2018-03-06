//
//  HamburgerLayer.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

enum HamburgerLayer {
    case home
    case settings
    case contactUs
    case help
    case logout
    
    var name: String {
        switch self {
        case .home: return "Home"
        case .settings: return "Settings"
        case .contactUs: return "Contact Us"
        case .help: return "Help"
        case .logout: return "Logout"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "homeIcon"
        case .settings: return "settingsIcon"
        case .contactUs: return "callUsIcon"
        case .help: return "helpIcon"
        case .logout: return "logoutIcon"
        }
    }
    
    var identifier: String {
        return "HamburgerCell"
    }
}

