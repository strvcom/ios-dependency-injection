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
        let number: Int
        
        init(number: Int) {
            self.number = number
        }
    }
    
    func testRegistration() {
        let container = Container()

        container.register { (resolver, number: Int) -> Dependency in
            Dependency(number: number)
        }
        
        let number = 48
        let resolvedDependency: Dependency = container.resolve(argument: number)
        
        XCTAssertEqual(number, resolvedDependency.number, "Container returned dependency with different argument")
    }
}
