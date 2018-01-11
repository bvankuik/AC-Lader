//
//  Bundle+Extensions.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 13/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//


extension Bundle {
    
    // From: https://stackoverflow.com/a/40155409
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}
