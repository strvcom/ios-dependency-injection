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
    let factory: (DependencyResolving, Any?) throws -> Any

    /// Initializer for registrations that don't need any variable argument
    init<Dependency>(type: Dependency.Type, scope: DependencyScope, factory: @escaping (DependencyResolving) -> Dependency) {
        identifier = RegistrationIdentifier(type: type)
        self.scope = scope
        self.factory = { resolver, _ in factory(resolver) }
    }

    /// Initializer for registrations that expect a variable argument passed to the factory closure when the dependency is being resolved
    init<Dependency, Argument>(type: Dependency.Type, scope: DependencyScope, factory: @escaping (DependencyResolving, Argument) -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Swift.type(of: arg))")
            }

            return factory(resolver, argument)
        }
    }

    /// Initializer for registrations that expect two variable arguments passed to the factory closure when the dependency is being resolved
    init<Dependency, Argument1, Argument2>(type: Dependency.Type, scope: DependencyScope, factory: @escaping (DependencyResolving, Argument1, Argument2) -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument1.self, Argument2.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(Swift.type(of: arg))")
            }

            return factory(resolver, arguments.0, arguments.1)
        }
    }

    /// Initializer for registrations that expect three variable arguments passed to the factory closure when the dependency is being resolved
    init<Dependency, Argument1, Argument2, Argument3>(type: Dependency.Type, scope: DependencyScope, factory: @escaping (DependencyResolving, Argument1, Argument2, Argument3) -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument1.self, Argument2.self, Argument3.self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2, Argument3) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(Swift.type(of: arg))")
            }

            return factory(resolver, arguments.0, arguments.1, arguments.2)
        }
    }
}
