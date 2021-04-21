//
//  SharedContainerIdentifierTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
import DependencyInjection

final class SharedContainerIdentifierTests: XCTestCase {
    class Dependency {}
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.clean()
    }
    
    func testSimpleRegistration() {
        let dependency = Dependency()
        let identifier = UUID().uuidString
        
        Container.register(with: identifier, dependency: dependency)
        
        let resolvedDependency: Dependency = Container.resolve(with: identifier)
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
}
