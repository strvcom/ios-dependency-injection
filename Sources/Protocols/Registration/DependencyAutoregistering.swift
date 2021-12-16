//
//  DependencyAutoregistering.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import Foundation

public protocol DependencyAutoregistering: DependencyRegistering {
    func autoregister<Dependency>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping () -> Dependency
    )
    func autoregister<Dependency, Parameter1>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1) -> Dependency
    )
    func autoregister<Dependency, Parameter1, Parameter2>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2) -> Dependency
    )
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3) -> Dependency
    )
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4) -> Dependency
    )
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4, Parameter5) -> Dependency
    )
}

// MARK: Default implementation
public extension DependencyAutoregistering {
    func autoregister<Dependency>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping () -> Dependency
    ) {
        let factory: Resolver<Dependency> = { _ in
            initializer()
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<Dependency, Parameter1>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1) -> Dependency
    ) {
        let factory: Resolver<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<Dependency, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2) -> Dependency
    ) {
        let factory: Resolver<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3) -> Dependency
    ) {
        let factory: Resolver<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                resolver.resolve(type: Parameter3.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4) -> Dependency
    ) {
        let factory: Resolver<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                resolver.resolve(type: Parameter3.self),
                resolver.resolve(type: Parameter4.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4, Parameter5) -> Dependency
    ) {
        let factory: Resolver<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                resolver.resolve(type: Parameter3.self),
                resolver.resolve(type: Parameter4.self),
                resolver.resolve(type: Parameter5.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
}
