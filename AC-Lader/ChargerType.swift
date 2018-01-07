//
//  ChargerType.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import Foundation

class ChargerType {
    let sequence: Int
    let image: UIImage
    var title: String?
    let resourceName: String
    var kmlParser: GMUKMLParser?
    var isHidden: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ChargerType.defaultsKey(sequence: self.sequence))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ChargerType.defaultsKey(sequence: self.sequence))
        }
    }
    
    func parse() {
        guard let path = Bundle.main.path(forResource: self.resourceName, ofType: "kml") else {
            fatalError("Couldn't load chargers KML file \(self.resourceName)")
        }
        
        let url = URL(fileURLWithPath: path)
        let kmlParser = GMUKMLParser(url: url)
        kmlParser.parse()
        self.kmlParser = kmlParser
    }

    static func makeChargerTypes() -> [ChargerType] {
        return constants.chargerTypes.map {
            ChargerType(sequence: $0.sequence, resourceName: $0.resourceName, imageName: $0.imageName)
        }
    }
    
    static func defaultsKey(sequence: Int) -> String {
        let key = String(format: "%@%d", constants.defaults.chargerTypeHiddenKey, sequence)
        return key
    }
    
    private init(sequence: Int, resourceName: String, imageName: String) {
        self.sequence = sequence
        self.title = resourceName
        self.resourceName = resourceName
        if let image = UIImage(named: imageName) {
            self.image = image
        } else {
            fatalError("Image not found for \(resourceName)")
        }
    }
}


