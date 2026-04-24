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

    /// Initializer for registrations that expect variable arguments passed to the factory closure when the dependency is being resolved
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single initializer. Entering more arguments will cause error in runtime.
    init<Dependency, each Argument>(type: Dependency.Type, scope: DependencyScope, factory: @escaping (DependencyResolving, repeat each Argument) -> Dependency) {
        let registrationIdentifier = RegistrationIdentifier(type: type, argumentTypes: repeat (each Argument).self)

        identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let arguments = arg as? (repeat each Argument) else {
                throw ResolutionError.unmatchingArgumentType(
                    message: "Registration of type \(registrationIdentifier.description) doesn't accept arguments of type \(runtimeTypeDescription(of: arg))"
                )
            }

            return factory(resolver, repeat each arguments)
        }
    }
}
