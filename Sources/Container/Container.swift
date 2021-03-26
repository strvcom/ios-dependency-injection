//
//  DIContainer.swift
//  
//
//  Created by Jan Schwarz on 24.03.2021.
//

import Foundation

open class Container {
    static var shared: Container!
    
    private var registrations = [RegistrationIdentfier: Registration]()
    private var sharedInstances = [RegistrationIdentfier: Any]()
    
    open class func configure() {
        Self.shared = Container()
    }
    
    open func clean() {
        registrations.removeAll()
        sharedInstances.removeAll()
    }
}

// MARK: Static methods
public extension Container {
    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, factory: @escaping (DependencyResolving) -> T) {
        shared.register(type: type, in: scope, factory: factory)
    }
    
    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, dependency: @autoclosure @escaping () -> T) {
        shared.register(type: type, in: scope, factory: { _ -> T in dependency() })
    }
    
    static func resolve<T>(type: T.Type = T.self) -> T {
        shared.resolve(type: type)
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
    open func tryResolve<T>(type: T.Type) throws -> T {
        let identifier = RegistrationIdentfier(type: type)
        
        guard let registration = registrations[identifier] else {
            throw ResolvingError.dependencyNotRegistered(
                message: "Dependency of type \(identifier.description) wasn't registered in container \(self)"
            )
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
            throw ResolvingError.unmatchingType(
                message: "Registration of type \(identifier.description) doesn't return an instance of type \(type)"
            )
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
