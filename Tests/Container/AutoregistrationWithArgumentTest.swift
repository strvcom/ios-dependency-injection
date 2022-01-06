//
//  AutoregistrationWithArgumentTest.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import XCTest
import DependencyInjection

final class AutoregistrationWithArgumentTest: XCTestCase {
    class Dependency {
        let number: Int
        let subdependency: Subdependency

        init(number: Int, subdependency: Subdependency) {
            self.number = number
            self.subdependency = subdependency
        }
    }
    
    class Subdependency {}

    func testRegistration() {
        let container = Container()

        let subdependency = Subdependency()
        container.register(dependency: subdependency)
        container.autoregister(argument: Int.self, initializer: Dependency.init)

        let number = 48
        let firstResolved: Dependency = container.resolve(argument: number)
        
        XCTAssertEqual(number, firstResolved.number, "Container returned dependency with different argument")
        
        XCTAssertTrue(subdependency === firstResolved.subdependency, "Different instances of subdependencies")
    }
}
