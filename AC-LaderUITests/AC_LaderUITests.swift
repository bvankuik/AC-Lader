//
//  AC_LaderUITests.swift
//  AC-LaderUITests
//
//  Created by Bart van Kuik on 15/03/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import XCTest

class AC_LaderUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        snapshot("0launch")
    }
    
}
