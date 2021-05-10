//
//  Registration.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct Registration {
    let identifier: RegistrationIdentfier
    let scope: DependencyScope
    let factory: (DependencyWithArgumentResolving, Any?) throws -> Any

    init<T>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        self.identifier = RegistrationIdentfier(type: type)
        self.scope = scope
        self.factory = { resolver, _ in factory(resolver) }
    }

    init<T, Argument>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyWithArgumentResolving, Argument) -> T) {
        let registrationIdentifier = RegistrationIdentfier(type: type, argument: Argument.self)
        
        self.identifier = registrationIdentifier
        self.scope = scope
        self.factory = { resolver, arg in
            guard let argument = arg as? Argument else {
                throw ResolvingError.unmatchingArgumentType(message: "Registration of type \(registrationIdentifier.description) doesn't accept an argument of type \(Argument.self)")
            }
            
            return factory(resolver, argument)
        }
    }
}
