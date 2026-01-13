//
//  AsyncContainer.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

import Foundation

/// Dependency Injection Container where dependencies are registered and from where they are consequently retrieved (i.e. resolved)
public actor AsyncContainer: AsyncDependencyResolving, AsyncDependencyRegistering {
    /// Shared singleton
    public static let shared: AsyncContainer = {
        AsyncContainer()
    }()
    
    private var registrations = [RegistrationIdentifier: AsyncRegistration]()
    private var sharedInstances = [RegistrationIdentifier: Any]()
    
    /// Create new instance of ``AsyncContainer``
    public init() {}
    
    /// Remove all registrations and already instantiated shared instances from the container
    public func clean() {
        registrations.removeAll()
        
        releaseSharedInstances()
    }
    
    /// Remove already instantiated shared instances from the container
    public func releaseSharedInstances() {
        sharedInstances.removeAll()
    }

    // MARK: Register dependency
    
    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    public func register<Dependency>(
        type: Dependency.Type,
        in scope: DependencyScope,
        factory: @escaping Factory<Dependency>
    ) async {
        let registration = AsyncRegistration(type: type, scope: scope, factory: factory)
        
        registrations[registration.identifier] = registration
        
        // With a new registration we should clean all shared instances
        // because the new registered factory most likely returns different objects and we have no way to tell
        sharedInstances[registration.identifier] = nil
    }

    // MARK: Register dependency with argument

    /// Register a dependency with an argument
    ///
    /// The argument is typically a parameter in an initiliazer of the dependency that is not registered in the same container,
    /// therefore, it needs to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    public func register<Dependency, Argument>(type: Dependency.Type, factory: @escaping FactoryWithOneArgument<Dependency, Argument>) async {
        let registration = AsyncRegistration(type: type, scope: .new, factory: factory)
        
        registrations[registration.identifier] = registration
    }

    // MARK: Resolve dependency

    /// Resolve a dependency that was previously registered with `register` method
    ///
    /// If a dependency of the given type with the given argument wasn't registered before this method call
    /// the method throws ``ResolutionError.dependencyNotRegistered``
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will passed as an input parameter to the factory method that was defined with `register` method
    public func tryResolve<Dependency: Sendable, Argument: Sendable>(type: Dependency.Type, argument: Argument) async throws -> Dependency {
        let identifier = RegistrationIdentifier(type: type, argument: Argument.self)

        let registration = try getRegistration(with: identifier)
        
        let dependency: Dependency = try await getDependency(from: registration, with: argument)

        return dependency
    }
    
    /// Resolve a dependency that was previously registered with `register` method
    ///
    /// If a dependency of the given type wasn't registered before this method call
    /// the method throws ``ResolutionError.dependencyNotRegistered``
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    public func tryResolve<Dependency: Sendable>(type: Dependency.Type) async throws -> Dependency {
        let identifier = RegistrationIdentifier(type: type)

        let registration = try getRegistration(with: identifier)
        
        let dependency: Dependency = try await getDependency(from: registration)
        
        return dependency
    }
}

// MARK: Private methods
private extension AsyncContainer {
    func getRegistration(with identifier: RegistrationIdentifier) throws -> AsyncRegistration {
        guard let registration = registrations[identifier] else {
            throw ResolutionError.dependencyNotRegistered(
                message: "Dependency of type \(identifier.description) wasn't registered in container \(self)"
            )
        }
        
        return registration
    }
    
    func getDependency<Dependency: Sendable>(from registration: AsyncRegistration, with argument: (any Sendable)? = nil) async throws -> Dependency {
        switch registration.scope {
        case .shared:
            if let dependency = sharedInstances[registration.identifier] as? Dependency {
                return dependency
            }
        case .new:
            break
        }
        
        // We use force cast here because we are sure that the type-casting always succeed
        // The reason why the `factory` closure returns ``Any`` is that we have to erase the generic type in order to store the registration
        // When the registration is created it can be initialized just with a `factory` that returns the matching type
        let dependency = try await registration.asyncRegistrationFactory(self, argument) as! Dependency
        
        switch registration.scope {
        case .shared:
            sharedInstances[registration.identifier] = dependency
        case .new:
            break
        }

        return dependency
    }
}
