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
    
    open func clean() {
        registrations.removeAll()
        sharedInstances.removeAll()
    }
}

// MARK: Register, Autoregister
extension Container: DependencyAutoregistering {
    /// Register a dependency
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all upcoming `resolve` calls i.e. it is a singleton
    ///   - factory: Closure that is called once the dependency is being resolved
    open func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Resolver<Dependency>) {
        let registration = Registration(type: type, scope: scope, factory: factory)
        
        registrations[registration.identifier] = registration
    }
}

// MARK: Register, Autoregister with argument
extension Container: DependencyWithArgumentAutoregistering {
    /// Register a dependency with an argument
    ///
    /// The argument is typically a parameter in an initiliazer of the dependency that is not registered in the same container,
    /// therefore, it needs to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to `Equatable` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called once the dependency is being resolved
    open func register<Dependency, Argument>(type: Dependency.Type, factory: @escaping ResolverWithArgument<Dependency, Argument>) {
        let registration = Registration(type: type, scope: .new, factory: factory)
        
        registrations[registration.identifier] = registration
    }
}

// MARK: Resolve
extension Container: DependencyWithArgumentResolving {
    /// Resolve a dependency that was previously registered with `register` method
    ///
    /// If a dependency of the given type with the given argument wasn't registered before this method call
    /// the method throws `ResolutionError.dependencyNotRegistered`
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will passed as an input parameter to the factory method that was defined with `register` method
    open func tryResolve<Dependency, Argument>(type: Dependency.Type, argument: Argument) throws -> Dependency {
        let identifier = RegistrationIdentfier(type: type, argument: Argument.self)

        let registration = try getRegistration(with: identifier)
        
        let dependency: Dependency = try getDependency(from: registration, with: argument)

        return dependency
    }
    
    /// Resolve a dependency that was previously registered with `register` method
    ///
    /// If a dependency of the given type wasn't registered before this method call
    /// the method throws `ResolutionError.dependencyNotRegistered`
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    open func tryResolve<Dependency>(type: Dependency.Type) throws -> Dependency {
        let identifier = RegistrationIdentfier(type: type)

        let registration = try getRegistration(with: identifier)
        
        let dependency: Dependency = try getDependency(from: registration)
        
        return dependency
    }
    
    private func getRegistration(with identifier: RegistrationIdentfier) throws -> Registration {
        guard let registration = registrations[identifier] else {
            throw ResolutionError.dependencyNotRegistered(
                message: "Dependency of type \(identifier.description) wasn't registered in container \(self)"
            )
        }
        
        return registration
    }
    
    private func getDependency<Dependency>(from registration: Registration, with argument: Any? = nil) throws -> Dependency {
        switch registration.scope {
        case .shared:
            if let dependency = sharedInstances[registration.identifier] as? Dependency {
                return dependency
            }
        case .new:
            break
        }
        
        // We use force cast here because we are sure that the type-casting always succeed
        // The reason why the `factory` closure returns `Any` is that we have to erase the generic type in order to store the registration
        // When the registration is created it can be initialized just with a `factory` that returns the matching type
        let dependency = try registration.factory(self, argument) as! Dependency
        
        switch registration.scope {
        case .shared:
            sharedInstances[registration.identifier] = dependency
        case .new:
            break
        }

        return dependency
    }
}
