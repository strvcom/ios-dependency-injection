//
//  DITestCase.swift
//  
//
//  Created by Jan Schwarz on 04.01.2022.
//

import XCTest
import DependencyInjection

class DITestCase: XCTestCase {
    var container: Container!
    
    override func setUp() {
        super.setUp()
        
        container = Container()
    }

    override func tearDown() {
        container = nil
        
        super.tearDown()
    }
}
