//
//  SharedContainerBaseTests.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import XCTest
import DependencyInjection

final class SharedContainerBaseTests: XCTestCase {
    class Dependency {}
    
    override func tearDown() {
        super.tearDown()
        
        Container.clean()
    }
    
    func testSharedAutoRegistration() {
        let dependency = Dependency()
        Container.register(dependency: dependency)
        
        let resolvedDependency: Dependency = Container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
}
