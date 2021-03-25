//
//  DIContainer.swift
//  
//
//  Created by Jan Schwarz on 24.03.2021.
//

import Foundation

open class Container {
    let text = "Hello world!"
    
    public static var shared: Container!
    
    private var registrations = [RegistrationIdentfier: Registration]()
    private var sharedInstances = [RegistrationIdentfier: Any]()
    
    open func clean() {
        registrations.removeAll()
        sharedInstances.removeAll()
    }
}

// MARK: Register
extension Container: DependencyRegistering {
    open func register<T>(type: T.Type, in scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        let registration = Registration(type: type, scope: scope, factory: factory)
        
        registrations[registration.identifier] = registration
    }
}

// MARK: Resolve
extension Container: DependencyResolving {
    open func resolve<T>(type: T.Type) -> T {
        let identifier = RegistrationIdentfier(type: type)
        
        guard let registration = registrations[identifier] else {
            fatalError("Dependency of type \(identifier.description) wasn't registered in container \(self)")
        }
        
        switch registration.scope {
        case .shared:
            if let dependency = sharedInstances[identifier] as? T {
                return dependency
            }
        case .new:
            break
        }
        
        guard let dependency = registration.factory(self) as? T else {
            fatalError("Registration of type \(identifier.description) doesn't return an instance of type \(type)")
        }
        
        switch registration.scope {
        case .shared:
            sharedInstances[identifier] = dependency
        case .new:
            break
        }
        
        return dependency
    }
}
