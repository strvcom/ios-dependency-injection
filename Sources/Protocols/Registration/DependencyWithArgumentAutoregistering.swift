//
//  DependencyWithArgumentAutoregistering.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import Foundation

public protocol DependencyWithArgumentAutoregistering: DependencyWithArgumentRegistering {
    // MARK: Initializer with argument and 1 parameter

    /// Autoregister a dependency with the provided initializer method and with a variable argument
    ///
    /// The `Argument` and `Parameter1` are both parameters of the given initializer.
    /// However, `Parameter1` is a dependency registered in the same resolver e.g. container,
    /// whereas `Argument` is not registered in the same resolver and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The resolver should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to `Equatable` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the resolver.
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1) -> Dependency
    )
    func autoregister<Dependency, Argument, Parameter1>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Argument) -> Dependency
    )
    
    // MARK: Initializer with argument and 2 parameters
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1, Parameter2) -> Dependency
    )
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Argument, Parameter2) -> Dependency
    )
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Parameter2, Argument) -> Dependency
    )
}

// MARK: Default implementation for initializer with argument and 1 parameter
public extension DependencyWithArgumentAutoregistering {
    func autoregister<Dependency, Argument, Parameter1>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: Parameter1.self)
            )
        }
        
        register(type: type, factory: factory)
    }
    
    func autoregister<Dependency, Argument, Parameter1>(type: Dependency.Type = Dependency.self, argument: Argument.Type, initializer: @escaping (Parameter1, Argument) -> Dependency) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter1.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}

// MARK: Default implementation for initializer with argument and 2 parameters
public extension DependencyWithArgumentAutoregistering {
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1, Parameter2) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Argument, Parameter2) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter1.self),
                argument,
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Parameter2, Argument) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}
