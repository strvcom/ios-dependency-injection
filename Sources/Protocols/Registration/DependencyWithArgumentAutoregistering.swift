//
//  DependencyWithArgumentAutoregistering.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import Foundation

public protocol DependencyWithArgumentAutoregistering: DependencyWithArgumentRegistering {
    // MARK: Initializer with argument and 1 parameter
    func autoregister<T, Argument, A>(
        type: T.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, A) -> T
    )
    func autoregister<T, Argument, A>(
        type: T.Type,
        argument: Argument.Type,
        initializer: @escaping (A, Argument) -> T
    )
    
    // MARK: Initializer with argument and 2 parameters
    func autoregister<T, Argument, A, B>(
        type: T.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, A, B) -> T
    )
    func autoregister<T, Argument, A, B>(
        type: T.Type,
        argument: Argument.Type,
        initializer: @escaping (A, Argument, B) -> T
    )
    func autoregister<T, Argument, A, B>(
        type: T.Type,
        argument: Argument.Type,
        initializer: @escaping (A, B, Argument) -> T
    )
}

// MARK: Default implementation for initializer with argument and 1 parameter
public extension DependencyWithArgumentAutoregistering {
    func autoregister<T, Argument, A>(type: T.Type = T.self, argument: Argument.Type, initializer: @escaping (Argument, A) -> T) {
        let factory: ResolverWithArgument<T, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: A.self)
            )
        }
        
        register(type: type, factory: factory)
    }
    
    func autoregister<T, Argument, A>(type: T.Type = T.self, argument: Argument.Type, initializer: @escaping (A, Argument) -> T) {
        let factory: ResolverWithArgument<T, Argument> = { resolver, argument in
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
    func autoregister<T, Argument, A, B>(type: T.Type = T.self, argument: Argument.Type, initializer: @escaping (Argument, A, B) -> T) {
        let factory: ResolverWithArgument<T, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<T, Argument, A, B>(type: T.Type = T.self, argument: Argument.Type, initializer: @escaping (A, Argument, B) -> T) {
        let factory: ResolverWithArgument<T, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: A.self),
                argument,
                resolver.resolve(type: B.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    func autoregister<T, Argument, A, B>(type: T.Type = T.self, argument: Argument.Type, initializer: @escaping (A, B, Argument) -> T) {
        let factory: ResolverWithArgument<T, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}
