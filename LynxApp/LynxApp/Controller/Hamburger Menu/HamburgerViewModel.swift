//
//  HamburgerViewModel.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import Foundation

class HamburgerViewModel: NSObject {
    
    func allLayers() -> [HamburgerLayer] {
        
        var layers: [HamburgerLayer] = []
        
        layers.append(.home)
        layers.append(.settings)
        layers.append(.contactUs)
        layers.append(.help)
        layers.append(.logout)
        
        return layers
    }
}
