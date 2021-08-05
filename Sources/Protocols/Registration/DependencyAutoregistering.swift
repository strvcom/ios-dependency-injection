//
//  DependencyAutoregistering.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import Foundation

public protocol DependencyAutoregistering: DependencyRegistering {
    
    func autoregister<T, A>(type: T.Type, in scope: DependencyScope, initializer: @escaping (A) -> T)
    func autoregister<T, A, B>(type: T.Type, in scope: DependencyScope, initializer: @escaping (A, B) -> T)
    func autoregister<T, A, B, C>(type: T.Type, in scope: DependencyScope, initializer: @escaping (A, B, C) -> T)
    func autoregister<T, A, B, C, D>(type: T.Type, in scope: DependencyScope, initializer: @escaping (A, B, C, D) -> T)
    func autoregister<T, A, B, C, D, E>(type: T.Type, in scope: DependencyScope, initializer: @escaping (A, B, C, D, E) -> T)
}

// MARK: Default implementation
public extension DependencyAutoregistering {
    func autoregister<T, A>(type: T.Type = T.self, in scope: DependencyScope = Self.defaultScope, initializer: @escaping (A) -> T) {
        let factory: Resolver<T> = { resolver in
            initializer(
                resolver.resolve(type: A.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<T, A, B>(type: T.Type = T.self, in scope: DependencyScope = Self.defaultScope, initializer: @escaping (A, B) -> T) {
        let factory: Resolver<T> = { resolver in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<T, A, B, C>(type: T.Type = T.self, in scope: DependencyScope = Self.defaultScope, initializer: @escaping (A, B, C) -> T) {
        let factory: Resolver<T> = { resolver in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self),
                resolver.resolve(type: C.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<T, A, B, C, D>(type: T.Type = T.self, in scope: DependencyScope = Self.defaultScope, initializer: @escaping (A, B, C, D) -> T) {
        let factory: Resolver<T> = { resolver in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self),
                resolver.resolve(type: C.self),
                resolver.resolve(type: D.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<T, A, B, C, D, E>(type: T.Type = T.self, in scope: DependencyScope = Self.defaultScope, initializer: @escaping (A, B, C, D, E) -> T) {
        let factory: Resolver<T> = { resolver in
            initializer(
                resolver.resolve(type: A.self),
                resolver.resolve(type: B.self),
                resolver.resolve(type: C.self),
                resolver.resolve(type: D.self),
                resolver.resolve(type: E.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
}
