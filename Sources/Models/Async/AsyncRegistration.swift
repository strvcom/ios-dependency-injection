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

    /// Initializer for registrations that expect variable arguments passed to the factory closure when the dependency is being resolved
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single initializer.
    init<Dependency: Sendable, each Argument: Sendable>(type: Dependency.Type, scope: DependencyScope, factory: @Sendable @escaping (any AsyncDependencyResolving, repeat each Argument) async -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: repeat (each Argument).self)

        identifier = registrationIdentifier
        self.scope = scope
        asyncRegistrationFactory = { resolver, arg in
            guard let arguments = arg as? (repeat each Argument) else {
                throw ResolutionError.unmatchingArgumentType(
                    message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(Swift.type(of: arg))"
                )
            }

            return await factory(resolver, repeat each arguments)
        }
    }
}
