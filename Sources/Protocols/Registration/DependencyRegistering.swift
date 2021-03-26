//
//  DependencyRegistering.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyRegistering {
    typealias Resolver<T> = (DependencyResolving) -> T
    
    func register<T>(type: T.Type, in scope: DependencyScope, with identifier: String?, factory: @escaping Resolver<T>)
}

// MARK: Overloaded factory methods
public extension DependencyRegistering {
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }
    
    func register<T>(type: T.Type, in scope: DependencyScope, factory: @escaping Resolver<T>) {
        register(type: type, in: Self.defaultScope, with: nil, factory: factory)
    }
    
    func register<T>(type: T.Type, with identifier: String?, factory: @escaping Resolver<T>) {
        register(type: type, in: Self.defaultScope, with: identifier, factory: factory)
    }
    
    func register<T>(in scope: DependencyScope, with identifier: String?, factory: @escaping Resolver<T>) {
        register(type: T.self, in: scope, with: identifier, factory: factory)
    }

    func register<T>(type: T.Type, factory: @escaping Resolver<T>) {
        register(type: type, in: Self.defaultScope, with: nil, factory: factory)
    }
    
    func register<T>(in scope: DependencyScope, factory: @escaping Resolver<T>) {
        register(type: T.self, in: scope, with: nil, factory: factory)
    }
    
    func register<T>(with identifier: String?, factory: @escaping Resolver<T>) {
        register(type: T.self, in: Self.defaultScope, with: identifier, factory: factory)
    }

    func register<T>(factory: @escaping Resolver<T>) {
        register(type: T.self, in: Self.defaultScope, with: nil, factory: factory)
    }
}

// MARK: Overloaded autoregistration methods
public extension DependencyRegistering {
    func register<T>(type: T.Type, in scope: DependencyScope, dependency: @autoclosure @escaping () -> T) {
        register(type: type, in: scope, with: nil) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(type: T.Type, with identifier: String?, dependency: @autoclosure @escaping () -> T) {
        register(type: type, in: Self.defaultScope, with: identifier) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(in scope: DependencyScope, with identifier: String?, dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: scope, with: identifier) { _ -> T in
            dependency()
        }
    }

    func register<T>(type: T.Type, dependency: @autoclosure @escaping () -> T) {
        register(type: type, in: Self.defaultScope, with: nil) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(in scope: DependencyScope, dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: scope, with: nil) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(with identifier: String?, dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: Self.defaultScope, with: identifier) { _ -> T in
            dependency()
        }
    }

    func register<T>(dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: Self.defaultScope, with: nil) { _ -> T in
            dependency()
        }
    }
}
