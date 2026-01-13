//
//  AutoregistrationTests.swift
//
//
//  Created by Jan Schwarz on 05.08.2021.
//

import DependencyInjection
import Testing

struct AutoregistrationTests {
    @Test func sharedAutoRegistrationWithoutParameter() {
        // Given
        let subject = Container()
        subject.autoregister(initializer: SimpleDependency.init)

        // When
        let firstResolved: SimpleDependency = subject.resolve()
        let secondResolved: SimpleDependency = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }

    @Test func sharedAutoRegistrationOneParameter() {
        // Given
        let subject = Container()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.autoregister(initializer: DependencyWithParameter.init)

        // When
        let firstResolved: DependencyWithParameter = subject.resolve()
        let secondResolved: DependencyWithParameter = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }

    @Test func sharedAutoRegistrationTwoParameters() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: DependencyWithParameter2.init)

        // When
        let firstResolved: DependencyWithParameter2 = subject.resolve()
        let secondResolved: DependencyWithParameter2 = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }

    @Test func sharedAutoRegistrationThreeParameters() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: DependencyWithParameter.init)
        subject.autoregister(initializer: DependencyWithParameter3.init)

        // When
        let firstResolved: DependencyWithParameter3 = subject.resolve()
        let secondResolved: DependencyWithParameter3 = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }

    @Test func sharedAutoRegistrationFourParameters() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: DependencyWithParameter.init)
        subject.autoregister(initializer: DependencyWithParameter2.init)
        subject.autoregister(initializer: DependencyWithParameter4.init)

        // When
        let firstResolved: DependencyWithParameter4 = subject.resolve()
        let secondResolved: DependencyWithParameter4 = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }

    @Test func sharedAutoRegistrationFiveParameters() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: DependencyWithParameter.init)
        subject.autoregister(initializer: DependencyWithParameter2.init)
        subject.autoregister(initializer: DependencyWithParameter3.init)
        subject.autoregister(initializer: DependencyWithParameter5.init)

        // When
        let firstResolved: DependencyWithParameter5 = subject.resolve()
        let secondResolved: DependencyWithParameter5 = subject.resolve()

        // Then
        #expect(firstResolved === secondResolved)
    }
}
