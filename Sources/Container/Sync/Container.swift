//
//  Container.swift
//
//
//  Created by Jan Schwarz on 24.03.2021.
//

import Foundation

/// Dependency Injection Container where dependencies are registered and from where they are consequently retrieved (i.e. resolved)
open class Container: DependencyAutoregistering, DependencyResolving, DependencyRegistering, @unchecked Sendable {
    /// Shared singleton
    public static let shared: Container = .init()

    private var registrations = [RegistrationIdentifier: Registration]()
    private var sharedInstances = [RegistrationIdentifier: Any]()

    /// Create new instance of ``Container``
    public init() {}

    /// Remove all registrations and already instantiated shared instances from the container
    open func clean() {
        registrations.removeAll()

        releaseSharedInstances()
    }

    /// Remove already instantiated shared instances from the container
    open func releaseSharedInstances() {
        sharedInstances.removeAll()
    }

    // MARK: Register dependency, Autoregister dependency

    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    open func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Factory<Dependency>) {
        let registration = Registration(type: type, scope: scope, factory: factory)

        registrations[registration.identifier] = registration

        // With a new registration we should clean all shared instances
        // because the new registered factory most likely returns different objects and we have no way to tell
        sharedInstances[registration.identifier] = nil
    }

    // MARK: Register dependency with arguments

    /// Register a dependency with variable arguments
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same container,
    /// therefore, they need to be passed in `resolve` call. This registration method doesn't have any scope parameter for a reason - the container
    /// should always return a new instance for dependencies with arguments.
    /// Argument matching is based on compile-time types, so registering with `ConcreteType` and resolving with `any Protocol`
    /// (or the other way around) creates different registrations.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    open func register<Dependency, each Argument>(type: Dependency.Type, factory: @escaping FactoryWithArguments<Dependency, repeat each Argument>) {
        let registration = Registration(type: type, scope: .new, factory: factory)

        registrations[registration.identifier] = registration
    }

    // MARK: Resolve dependency

    /// Resolve a dependency that was previously registered with `register` method
    ///
    /// If a dependency of the given type wasn't registered before this method call
    /// the method throws ``ResolutionError.dependencyNotRegistered``
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    open func tryResolve<Dependency>(type: Dependency.Type) throws -> Dependency {
        let identifier = RegistrationIdentifier(type: type)

        let registration = try getRegistration(with: identifier)

        return try getDependency(from: registration) as Dependency
    }

    /// Resolve a dependency with variable arguments that was previously registered with `register` method
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// If a dependency of the given type with the given arguments wasn't registered before this method call
    /// the method throws ``ResolutionError.dependencyNotRegistered``
    /// Argument matching is based on compile-time types, so `ConcreteType` and `any Protocol` are treated as different argument lists.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as input parameters to the factory method (Important: only 1-3 arguments supported. Entering more arguments will cause error in runtime.)
    open func tryResolve<Dependency, each Argument>(type: Dependency.Type, arguments: repeat each Argument) throws -> Dependency {
        let identifier = RegistrationIdentifier(type: type, argumentTypes: repeat (each Argument).self)

        if identifier.argumentCount > RegistrationIdentifierConstant.maximumArgumentCount {
            throw ResolutionError.tooManyArguments(
                message: "Maximum number of arguments is \(RegistrationIdentifierConstant.maximumArgumentCount). Got \(identifier.argumentCount)."
            )
        }

        let registration = try getRegistration(with: identifier)

        // Pack arguments into a tuple for storage - this matches how Registration expects them
        let argumentsTuple = (repeat each arguments)

        return try getDependency(from: registration, with: argumentsTuple) as Dependency
    }
}

// MARK: Private methods
private extension Container {
    func getRegistration(with identifier: RegistrationIdentifier) throws -> Registration {
        if let registration = registrations[identifier] {
            return registration
        }

        if let matchingIdentifier = registrations.keys.first(where: { $0.typeIdentifier == identifier.typeIdentifier }) {
            throw ResolutionError.unmatchingArgumentType(
                message: "Registration of type \(matchingIdentifier.description) doesn't accept arguments of type \(identifier.description)"
            )
        }

        throw ResolutionError.dependencyNotRegistered(
            message: "Dependency of type \(identifier.description) wasn't registered in container \(self)"
        )
    }

    func getDependency<Dependency>(from registration: Registration, with argument: Any? = ()) throws -> Dependency {
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
