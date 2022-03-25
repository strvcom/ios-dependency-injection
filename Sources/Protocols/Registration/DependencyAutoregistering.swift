//
//  DependencyAutoregistering.swift
//  
//
//  Created by Jan Schwarz on 05.08.2021.
//

import Foundation

/// A type that is able to register a dependency with a given initializer instead of a factory closure. All the initializer's parameters must be resolvable from the same container
public protocol DependencyAutoregistering: DependencyRegistering {
    /// Autoregister a dependency with the provided initializer method that has no parameters
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping () -> Dependency
    )
    
    /// Autoregister a dependency with the provided initializer method that has one parameter which is a dependency that is registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter) -> Dependency
    )
    
    /// Autoregister a dependency with the provided initializer method that has two parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2) -> Dependency
    )
    
    /// Autoregister a dependency with the provided initializer method that has three parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3) -> Dependency
    )
    
    /// Autoregister a dependency with the provided initializer method that has four parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4) -> Dependency
    )
    
    /// Autoregister a dependency with the provided initializer method that has five parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5>(
        type: Dependency.Type,
        in scope: DependencyScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4, Parameter5) -> Dependency
    )
}

// MARK: Default implementation
public extension DependencyAutoregistering {
    /// Autoregister a dependency with the provided initializer method that has no parameters
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping () -> Dependency
    ) {
        let factory: Factory<Dependency> = { _ in
            initializer()
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    /// Autoregister a dependency with the provided initializer method that has one parameter which is a dependency that is registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter) -> Dependency
    ) {
        let factory: Factory<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    /// Autoregister a dependency with the provided initializer method that has two parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2) -> Dependency
    ) {
        let factory: Factory<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    /// Autoregister a dependency with the provided initializer method that has three parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3) -> Dependency
    ) {
        let factory: Factory<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                resolver.resolve(type: Parameter3.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    /// Autoregister a dependency with the provided initializer method that has four parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4) -> Dependency
    ) {
        let factory: Factory<Dependency> = { resolver in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                resolver.resolve(type: Parameter3.self),
                resolver.resolve(type: Parameter4.self)
            )
        }
        
        register(type: type, in: scope, factory: factory)
    }
    
    /// Autoregister a dependency with the provided initializer method that has five parameters which are dependencies that are registered within the same container
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - scope: Scope of the dependency. If `.new` is used, the initializer is called on each `resolve` call. If `.shared` is used, the initializer is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton. The default value is `.shared`
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5>(
        type: Dependency.Type = Dependency.self,
        in scope: DependencyScope = Self.defaultScope,
        initializer: @escaping (Parameter1, Parameter2, Parameter3, Parameter4, Parameter5) -> Dependency
    ) {
        let factory: Factory<Dependency> = { resolver in
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
