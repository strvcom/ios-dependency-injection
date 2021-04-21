//
//  SharedContainerArgumentTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

import XCTest
import DependencyInjection

final class SharedContainerArgumentTests: XCTestCase {
    class Dependency {
        let sub: Subdependency
        
        init(sub: Subdependency) {
            self.sub = sub
        }
    }
    struct Subdependency {
        let id = UUID()
    }
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.clean()
    }

    func testRegistration() {
        Container.register { (resolver, sub: Subdependency) -> Dependency in
            Dependency(sub: sub)
        }
        
        let sub = Subdependency()
        let resolvedDependency: Dependency = Container.resolve(argument: sub)
        
        XCTAssertEqual(sub.id, resolvedDependency.sub.id, "Container returned dependency with different argument")
    }
}
