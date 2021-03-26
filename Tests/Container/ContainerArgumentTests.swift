//
//  ContainerArgumentTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerArgumentTests: XCTestCase {
    class Dependency {
        let sub: Subdependency
        
        init(sub: Subdependency) {
            self.sub = sub
        }
    }
    struct Subdependency {
        let id = UUID()
    }
    
    func testRegistration() {
        let container = Container()

        container.register { (resolver, sub: Subdependency) -> Dependency in
            Dependency(sub: sub)
        }
        
        let sub = Subdependency()
        let resolvedDependency: Dependency = container.resolve(argument: sub)
        
        XCTAssertEqual(sub.id, resolvedDependency.sub.id, "Container returned dependency with different argument")
    }
}
