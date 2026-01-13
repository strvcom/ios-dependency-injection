//
//  Registration.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Object that represents a registered dependency and stores a closure, i.e. a factory that returns the desired dependency
struct Registration {
    let identifier: RegistrationIdentifier
    let scope: DependencyScope
    let factory: (DependencyWithOneArgumentResolving, Any?) throws -> Any

    /// Initializer for registrations that don't need any variable argument
    init<T>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        identifier = RegistrationIdentifier(type: type)
        self.scope = scope
        self.factory = { resolver, _ in factory(resolver) }
    }

    /// Initializer for registrations that expect a variable argument passed to the factory closure when the dependency is being resolved
    init<T, Argument>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyWithOneArgumentResolving, Argument) -> T) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argument: Argument.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Argument.self)")
            }

            return factory(resolver, argument)
        }
    }

    /// Initializer for registrations that expect two variable arguments passed to the factory closure when the dependency is being resolved
    init<T, Argument1, Argument2>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyWithOneArgumentResolving, Argument1, Argument2) -> T) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argument1: Argument1.self, argument2: Argument2.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type (\(Argument1.self), \(Argument2.self))")
            }

            return factory(resolver, arguments.0, arguments.1)
        }
    }

    /// Initializer for registrations that expect three variable arguments passed to the factory closure when the dependency is being resolved
    init<T, Argument1, Argument2, Argument3>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyWithOneArgumentResolving, Argument1, Argument2, Argument3) -> T) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argument1: Argument1.self, argument2: Argument2.self, argument3: Argument3.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2, Argument3) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type (\(Argument1.self), \(Argument2.self), \(Argument3.self))")
            }

            return factory(resolver, arguments.0, arguments.1, arguments.2)
        }
    }
}
