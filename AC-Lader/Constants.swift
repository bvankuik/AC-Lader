//
//  Constants.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 02/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import Foundation

struct Constants {
    struct Defaults {
        let zoomKey = "zoom"
        let zoomValue: Float = 8.0
        let chargerTypeHiddenKey = "chargerTypeVisibility"
    }
    let defaults = Defaults()
    let apiKey = "AIzaSyArJO36haCK6XVQwh3nrwhCh1NPE4lAv9k"
    let apiKeyValid = ((Bundle.main.bundleIdentifier ?? "") == "nl.dutchvirtual.AC-Lader")
    let chargerTypes = [
        (sequence: 10, resourceName: "43kW AC (3x63A)  fast", isHidden: false, imageName: "mintGreenWithDot"),
        (sequence: 20, resourceName: "22kW AC (3x32A)  semi-fast", isHidden: false, imageName: "greenWithDot"),
        (sequence: 30, resourceName: "Planned & Under Construction", isHidden: true, imageName: "grayWithoutDot"),
    ]

    // Utrecht
    let initialPosition = (latitude: 52.092876, longitude: 5.104480)
}

let constants = Constants()
