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
        let number: Int
        
        init(number: Int) {
            self.number = number
        }
    }

    override func tearDown() {
        super.tearDown()
        
        Container.shared.clean()
    }

    func testRegistration() {
        Container.register { (resolver, number: Int) -> Dependency in
            Dependency(number: number)
        }
        
        let number = 48
        let resolvedDependency: Dependency = Container.resolve(argument: number)
        
        XCTAssertEqual(number, resolvedDependency.number, "Container returned dependency with different argument")
    }
}
