//
//  ContainerTests.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import XCTest
@testable import DependencyInjection

final class ContainerTests: XCTestCase {
    class Dependency {
        
    }
    
    func testSimpleRegistration() {
        let container = Container()
        
        let dependency = Dependency()
        container.register(dependency: dependency)
        
        let resolvedDependency: Dependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
}
