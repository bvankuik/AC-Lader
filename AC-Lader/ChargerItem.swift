//
//  ChargerItem.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import Foundation


class ChargerItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String
    var type: ChargerType
    
    init(position: CLLocationCoordinate2D, name: String, type: ChargerType) {
        self.position = position
        self.name = name
        self.type = type
    }
}
