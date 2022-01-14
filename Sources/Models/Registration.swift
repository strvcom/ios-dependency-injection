//
//  Registration.swift
//  
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Object that represents a registered dependency and stores a closure i.e. factory that returns the desired dependency
struct Registration {
    let identifier: RegistrationIdentfier
    let scope: DependencyScope
    let factory: (DependencyWithArgumentResolving, Any?) throws -> Any
    
    /// Initializer for registrations that don't need any variable argument
    init<T>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        self.identifier = RegistrationIdentfier(type: type)
        self.scope = scope
        self.factory = { resolver, _ in factory(resolver) }
    }

    /// Initializer for registrations that expect a variable argument passed to the factory closure when the dependency is being resolved
    init<T, Argument>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyWithArgumentResolving, Argument) -> T) {
        let registrationIdentifier = RegistrationIdentfier(type: type, argument: Argument.self)
        
        self.identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolutionError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Argument.self)")
            }
            
            return factory(resolver, argument)
        }
    }
}
