//
//  AsyncRegistration.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 16.12.2024.
//

import Foundation

typealias AsyncRegistrationFactory = @Sendable (any AsyncDependencyResolving, (any Sendable)?) async throws -> any Sendable

/// Object that represents a registered dependency and stores a closure, i.e. a factory that returns the desired dependency
struct AsyncRegistration: Sendable {
    let identifier: RegistrationIdentifier
    let scope: DependencyScope
    let factory: AsyncRegistrationFactory
    
    /// Initializer for registrations that don't need any variable argument
    init<T: Sendable>(type: T.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving) async -> T) {
        self.identifier = RegistrationIdentifier(type: type)
        self.scope = scope
        self.factory = { resolver, _ in await factory(resolver) }
    }

    /// Initializer for registrations that expect a variable argument passed to the factory closure when the dependency is being resolved
    init<T: Sendable, Argument: Sendable>(type: T.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving, Argument) async -> T) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argument: Argument.self)
        
        self.identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Argument.self)")
            }
            
            return await factory(resolver, argument)
        }
    }
}
