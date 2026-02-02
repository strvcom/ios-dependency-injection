//
//  AsyncRegistration.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 16.12.2024.
//

import Foundation

typealias AsyncRegistrationFactory = @Sendable (any AsyncDependencyResolving, Any?) async throws -> any Sendable

/// Object that represents a registered dependency and stores a closure, i.e. a factory that returns the desired dependency
struct AsyncRegistration: Sendable {
    let identifier: RegistrationIdentifier
    let scope: DependencyScope
    let asyncRegistrationFactory: AsyncRegistrationFactory

    /// Initializer for registrations that don't need any variable argument
    init<Dependency: Sendable>(type: Dependency.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving) async -> Dependency) {
        identifier = RegistrationIdentifier(type: type)
        self.scope = scope
        asyncRegistrationFactory = { resolver, _ in await factory(resolver) }
    }

    /// Initializer for registrations that expect a variable argument passed to the factory closure when the dependency is being resolved
    init<Dependency: Sendable, Argument: Sendable>(type: Dependency.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving, Argument) async -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument.self)

        identifier = registrationIdentifier
        self.scope = scope
        asyncRegistrationFactory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Swift.type(of: arg))")
            }

            return await factory(resolver, argument)
        }
    }

    /// Initializer for registrations that expect two variable arguments passed to the factory closure when the dependency is being resolved
    init<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable>(type: Dependency.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving, Argument1, Argument2) async -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument1.self, Argument2.self)

        identifier = registrationIdentifier
        self.scope = scope
        asyncRegistrationFactory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(Swift.type(of: arg))")
            }

            return await factory(resolver, arguments.0, arguments.1)
        }
    }

    /// Initializer for registrations that expect three variable arguments passed to the factory closure when the dependency is being resolved
    init<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable, Argument3: Sendable>(type: Dependency.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving, Argument1, Argument2, Argument3) async -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: Argument1.self, Argument2.self, Argument3.self)

        identifier = registrationIdentifier
        self.scope = scope
        asyncRegistrationFactory = { resolver, arg in
            guard let arguments = arg as? (Argument1, Argument2, Argument3) else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(Swift.type(of: arg))")
            }

            return await factory(resolver, arguments.0, arguments.1, arguments.2)
        }
    }
}
