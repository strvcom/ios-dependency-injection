//
//  AutoregistrationTests.swift
//
//
//  Created by Jan Schwarz on 05.08.2021.
//

import DependencyInjection
import XCTest

final class AutoregistrationTests: DITestCase {
    func testSharedAutoRegistrationWithoutParameter() {
        container.autoregister(initializer: SimpleDependency.init)

        let firstResolved: SimpleDependency = container.resolve()
        let secondResolved: SimpleDependency = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }

    func testSharedAutoRegistrationOneParameter() {
        container.autoregister(initializer: SimpleDependency.init)
        container.autoregister(initializer: DependencyWithParameter.init)

        let firstResolved: DependencyWithParameter = container.resolve()
        let secondResolved: DependencyWithParameter = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }

    func testSharedAutoRegistrationTwoParameters() {
        let subDependency = DependencyWithValueTypeParameter()
        container.autoregister(initializer: SimpleDependency.init)
        container.register(dependency: subDependency)
        container.autoregister(initializer: DependencyWithParameter2.init)

        let firstResolved: DependencyWithParameter2 = container.resolve()
        let secondResolved: DependencyWithParameter2 = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }

    func testSharedAutoRegistrationThreeParameters() {
        let subDependency = DependencyWithValueTypeParameter()
        container.autoregister(initializer: SimpleDependency.init)
        container.register(dependency: subDependency)
        container.autoregister(initializer: DependencyWithParameter.init)
        container.autoregister(initializer: DependencyWithParameter3.init)

        let firstResolved: DependencyWithParameter3 = container.resolve()
        let secondResolved: DependencyWithParameter3 = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }

    func testSharedAutoRegistrationFourParameters() {
        let subDependency = DependencyWithValueTypeParameter()
        container.autoregister(initializer: SimpleDependency.init)
        container.register(dependency: subDependency)
        container.autoregister(initializer: DependencyWithParameter.init)
        container.autoregister(initializer: DependencyWithParameter2.init)
        container.autoregister(initializer: DependencyWithParameter4.init)

        let firstResolved: DependencyWithParameter4 = container.resolve()
        let secondResolved: DependencyWithParameter4 = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }

    func testSharedAutoRegistrationFiveParameters() {
        let subDependency = DependencyWithValueTypeParameter()
        container.autoregister(initializer: SimpleDependency.init)
        container.register(dependency: subDependency)
        container.autoregister(initializer: DependencyWithParameter.init)
        container.autoregister(initializer: DependencyWithParameter2.init)
        container.autoregister(initializer: DependencyWithParameter3.init)
        container.autoregister(initializer: DependencyWithParameter5.init)

        let firstResolved: DependencyWithParameter5 = container.resolve()
        let secondResolved: DependencyWithParameter5 = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }
}
