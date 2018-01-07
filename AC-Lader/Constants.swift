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
        let chargerTypeHiddenValue = [false, false, true]
    }
    let defaults = Defaults()
    let apiKey = "AIzaSyBRPakDGvYnKO70tKteJERj3gPaWuNNPqA"
    let chargerTypes = [
        (sequence: 10, resourceName: "43kW AC (3x63A)  fast", isHidden: false),
        (sequence: 20, resourceName: "22kW AC (3x32A)  semi-fast", isHidden: false),
        (sequence: 30, resourceName: "Planned & Under Construction", isHidden: true),
    ]
}

let constants = Constants()
