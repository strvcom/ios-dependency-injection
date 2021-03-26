//
//  DIContainer.swift
//  
//
//  Created by Jan Schwarz on 24.03.2021.
//

import Foundation

open class Container {
    private static var singleton: Container!
    
    private var registrations = [RegistrationIdentfier: Registration]()
    private var sharedInstances = [RegistrationIdentfier: Any]()
    
    public init() {}
    
    open class func configure() {
        Self.shared = Container()
    }
    
    open func clean() {
        registrations.removeAll()
        sharedInstances.removeAll()
    }
}

// MARK: Singleton methods
public extension Container {
    static var shared: Container {
        get {
            guard let shared = singleton else {
                fatalError("Shared value hasn't been configured. Call 'Container.configure()' before you start using Container as a singleton")
            }
            
            return shared
        }
        set {
            singleton = newValue
        }
    }

    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, with identifier: String? = nil, factory: @escaping (DependencyResolving) -> T) {
        shared.register(type: type, in: scope, with: identifier, factory: factory)
    }
    
    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, with identifier: String? = nil, dependency: @autoclosure @escaping () -> T) {
        shared.register(type: type, in: scope, with: identifier, factory: { _ -> T in dependency() })
    }
    
    static func resolve<T>(type: T.Type = T.self, with identifier: String? = nil) -> T {
        shared.resolve(type: type, with: identifier)
    }
}

// MARK: Register
extension Container: DependencyRegistering {
    open func register<T>(type: T.Type, in scope: DependencyScope, with identifier: String?, factory: @escaping (DependencyResolving) -> T) {
        let registration = Registration(type: type, scope: scope, identifier: identifier, factory: factory)
        
        registrations[registration.identifier] = registration
    }
}

// MARK: Resolve
extension Container: DependencyResolving {
    open func tryResolve<T>(type: T.Type, with identifier: String?) throws -> T {
        let identifier = RegistrationIdentfier(type: type, identifier: identifier)
        
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
