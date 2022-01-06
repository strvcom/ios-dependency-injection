//
//  ContainerBaseTests.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerBaseTests: XCTestCase {
    class Dependency {}
    
    func testSharedAutoclosureRegistration() {
        let container = Container()
        
        let dependency = Dependency()
        container.register(dependency: dependency)
        
        let resolvedDependency: Dependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
}
