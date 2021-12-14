//
//  DependencyWithArgumentAutoregistering.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import Foundation

public protocol DependencyWithArgumentAutoregistering: DependencyWithArgumentRegistering {
    // MARK: Initializer with argument and 1 parameter
    func autoregister<Dependency, Argument, A>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, A) -> Dependency
    )
    func autoregister<Dependency, Argument, A>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (A, Argument) -> Dependency
    )
    
    // MARK: Initializer with argument and 2 parameters
    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, A, B) -> Dependency
    )
    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (A, Argument, B) -> Dependency
    )
    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (A, B, Argument) -> Dependency
    )
}

// MARK: Default implementation for initializer with argument and 1 parameter
public extension DependencyWithArgumentAutoregistering {
    func autoregister<Dependency, Argument, A>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, A) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: A.self)
            )
        }
        
        register(type: type, factory: factory)
    }
    
    func autoregister<Dependency, Argument, A>(type: Dependency.Type = Dependency.self, argument: Argument.Type, initializer: @escaping (A, Argument) -> Dependency) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: A.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}

// MARK: Default implementation for initializer with argument and 2 parameters
public extension DependencyWithArgumentAutoregistering {
    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, A, B) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (A, Argument, B) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: A.self),
                argument,
                resolver.resolve(type: B.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<Dependency, Argument, A, B>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (A, B, Argument) -> Dependency
    ) {
        let factory: ResolverWithArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}
