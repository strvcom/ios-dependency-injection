//
//  AutoregistrationWithArgumentTest.swift
//
//
//  Created by Jan Schwarz on 05.08.2021.
//

import DependencyInjection
import Testing

@Suite("Container/Sync/Autoregistration with Arguments", .tags(.sync, .autoregistration, .arguments))
struct AutoregistrationWithArgumentTest {
    @Test("Registration without parameter")
    func registrationWithoutParameter() {
        // Given
        let subject = Container()
        subject.autoregister(argument: StructureDependency.self, initializer: DependencyWithValueTypeParameter.init)
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithValueTypeParameter = subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test("Registration with one parameter - first permutation")
    func registrationWithOneParameterFirstPermutation() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.register(dependency: subDependency)
        subject.autoregister(argument: SimpleDependency.self, initializer: DependencyWithParameter2.init)
        let argument = SimpleDependency()

        // When
        let firstResolved: DependencyWithParameter2 = subject.resolve(argument: argument)
        let secondResolved: DependencyWithParameter2 = subject.resolve(argument: argument)

        // Then
        #expect(argument === firstResolved.subDependency1)
        #expect(argument === secondResolved.subDependency1)
        #expect(firstResolved.subDependency2 === secondResolved.subDependency2)
    }

    @Test("Registration with one parameter - second permutation")
    func registrationWithOneParameterSecondPermutation() {
        // Given
        let subject = Container()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter2.init)
        let argument = DependencyWithValueTypeParameter()

        // When
        let firstResolved: DependencyWithParameter2 = subject.resolve(argument: argument)
        let secondResolved: DependencyWithParameter2 = subject.resolve(argument: argument)

        // Then
        #expect(argument === firstResolved.subDependency2)
        #expect(argument === secondResolved.subDependency2)
        #expect(firstResolved.subDependency1 === secondResolved.subDependency1)
    }

    @Test("Registration with two parameters - first permutation")
    func registrationWithTwoParameterFirstPermutation() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: SimpleDependency.init)
        subject.autoregister(initializer: DependencyWithParameter.init)
        subject.autoregister(argument: SimpleDependency.self, initializer: DependencyWithParameter3.init)
        let argument = SimpleDependency()

        // When
        let firstResolved: DependencyWithParameter3 = subject.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = subject.resolve(argument: argument)

        // Then
        #expect(argument === firstResolved.subDependency1)
        #expect(argument === secondResolved.subDependency1)
        #expect(firstResolved.subDependency2 === secondResolved.subDependency2)
        #expect(firstResolved.subDependency3 === secondResolved.subDependency3)
    }

    @Test("Registration with two parameters - second permutation")
    func registrationWithTwoParameterSecondPermutation() {
        // Given
        let subject = Container()
        subject.autoregister(initializer: SimpleDependency.init)
        subject.autoregister(initializer: DependencyWithParameter.init)
        subject.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter3.init)
        let argument = DependencyWithValueTypeParameter()

        // When
        let firstResolved: DependencyWithParameter3 = subject.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = subject.resolve(argument: argument)

        // Then
        #expect(argument === firstResolved.subDependency2)
        #expect(argument === secondResolved.subDependency2)
        #expect(firstResolved.subDependency1 === secondResolved.subDependency1)
        #expect(firstResolved.subDependency3 === secondResolved.subDependency3)
    }

    @Test("Registration with two parameters - third permutation")
    func registrationWithTwoParameterThirdPermutation() {
        // Given
        let subject = Container()
        let subDependency = DependencyWithValueTypeParameter()
        subject.register(dependency: subDependency)
        subject.autoregister(initializer: SimpleDependency.init)
        subject.autoregister(argument: DependencyWithParameter.self, initializer: DependencyWithParameter3.init)
        let argument = DependencyWithParameter(subDependency: SimpleDependency())

        // When
        let firstResolved: DependencyWithParameter3 = subject.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = subject.resolve(argument: argument)

        // Then
        #expect(argument === firstResolved.subDependency3)
        #expect(argument === secondResolved.subDependency3)
        #expect(firstResolved.subDependency2 === secondResolved.subDependency2)
        #expect(firstResolved.subDependency1 === secondResolved.subDependency1)
    }
}
