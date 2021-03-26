//
//  DIContainer.swift
//  
//
//  Created by Jan Schwarz on 24.03.2021.
//

import Foundation

open class Container {
    public static let shared: Container = {
        Container()
    }()
    
    private var registrations = [RegistrationIdentfier: Registration]()
    private var sharedInstances = [RegistrationIdentfier: Any]()
    
    public init() {}
    
    open class func clean() {
        shared.clean()
    }
    
    open func clean() {
        registrations.removeAll()
        sharedInstances.removeAll()
    }
}

// MARK: Singleton methods
public extension Container {
    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, with identifier: String? = nil, factory: @escaping Resolver<T>) {
        shared.register(type: type, in: scope, with: identifier, factory: factory)
    }
    
    static func register<T>(type: T.Type = T.self, in scope: DependencyScope = Container.defaultScope, with identifier: String? = nil, dependency: @autoclosure @escaping () -> T) {
        shared.register(type: type, in: scope, with: identifier, factory: { _ -> T in dependency() })
    }
    
    static func register<T, Argument>(type: T.Type = T.self, with identifier: String? = nil, factory: @escaping ResolverWithArgument<T, Argument>) {
        shared.register(type: type, with: identifier, factory: factory)
    }
    
    static func resolve<T>(type: T.Type = T.self, with identifier: String? = nil) -> T {
        shared.resolve(type: type, with: identifier)
    }
    
    static func resolve<T, Argument>(type: T.Type = T.self, with identifier: String? = nil, argument: Argument) -> T {
        shared.resolve(type: type, with: identifier, argument: argument)
    }
}

// MARK: Register
extension Container: DependencyWithArgumentRegistering {
    public func register<T, Argument>(type: T.Type, with identifier: String?, factory: @escaping ResolverWithArgument<T, Argument>) {
        let registration = Registration(type: type, scope: .new, identifier: identifier, factory: factory)
        
        registrations[registration.identifier] = registration
    }
    
    open func register<T>(type: T.Type, in scope: DependencyScope, with identifier: String?, factory: @escaping Resolver<T>) {
        let registration = Registration(type: type, scope: scope, identifier: identifier, factory: factory)
        
        registrations[registration.identifier] = registration
    }
}

// MARK: Resolve
extension Container: DependencyWithArgumentResolving {
    open func tryResolve<T, Argument>(type: T.Type, with identifier: String?, argument: Argument) throws -> T {
        let identifier = RegistrationIdentfier(type: type, identifier: identifier)

        let registration = try getRegistration(with: identifier)
        
        let dependency: T = try getDependency(from: registration, with: argument)

        return dependency
    }
    
    open func tryResolve<T>(type: T.Type, with identifier: String?) throws -> T {
        let identifier = RegistrationIdentfier(type: type, identifier: identifier)

        let registration = try getRegistration(with: identifier)
        
        let dependency: T = try getDependency(from: registration)
        
        return dependency
    }
    
    private func getRegistration(with identifier: RegistrationIdentfier) throws -> Registration {
        guard let registration = registrations[identifier] else {
            throw ResolvingError.dependencyNotRegistered(
                message: "Dependency of type \(identifier.description) wasn't registered in container \(self)"
            )
        }
        
        return registration
    }
    
    private func getDependency<T>(from registration: Registration, with argument: Any? = nil) throws -> T {
        switch registration.scope {
        case .shared:
            if let dependency = sharedInstances[registration.identifier] as? T {
                return dependency
            }
        case .new:
            break
        }
        
        guard let dependency = try registration.factory(self, argument) as? T else {
            throw ResolvingError.unmatchingDependencyType(
                message: "Registration of type \(registration.identifier.description) doesn't return an instance of type \(T.self)"
            )
        }
        
        switch registration.scope {
        case .shared:
            sharedInstances[registration.identifier] = dependency
        case .new:
            break
        }

        return dependency
    }
}
