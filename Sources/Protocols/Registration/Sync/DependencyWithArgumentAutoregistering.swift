//
//  DependencyWithArgumentAutoregistering.swift
//  
//
//  Created by Jan Schwarz on 05.08.2021.
//

import Foundation

/// A type that is able to register a dependency that needs a variable argument in order to be resolved later. The dependency is registered with a given initializer instead of a factory closure. All the initializer's parameters must be resolvable from the same container
public protocol DependencyWithArgumentAutoregistering: DependencyWithArgumentRegistering {
    // MARK: Initializer with a variable argument and no other parameter
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has one parameter where the variable argument is passed
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument) -> Dependency
    )
    
    // MARK: Initializer with a variable argument and 1 parameter

    /// Autoregister a dependency with a variable argument and with the provided initializer method that has two parameters; the first is the variable argument, the second is a dependency that is registered within the same container
    ///
    /// The `Argument` and `Parameter` are both parameters of the given initializer.
    /// However, `Parameter` is a dependency registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter) -> Dependency
    )
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has two parameters; the first is a dependency that is registered within the same container, the second is the variable argument
    ///
    /// The `Argument` and `Parameter` are both parameters of the given initializer.
    /// However, `Parameter` is a dependency registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter, Argument) -> Dependency
    )
    
    // MARK: Initializer with a variable argument and 2 parameters
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first is the variable argument, the second and the third are dependencies that are registered within the same container
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1, Parameter2) -> Dependency
    )
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first and the third are dependencies that are registered within the same container, the second is the variable argument
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Argument, Parameter2) -> Dependency
    )
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first and the second are dependencies that are registered within the same container, the third is the variable argument
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Parameter2, Argument) -> Dependency
    )
}

// MARK: Default implementation for an initializer with a variable argument
public extension DependencyWithArgumentAutoregistering {
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has just one parameter where the variable argument is passed
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument) -> Dependency
    ) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}

// MARK: Default implementation for an initializer with a variable argument and 1 parameter
public extension DependencyWithArgumentAutoregistering {
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has two parameters; the first is the variable argument, the second is a dependency that is registered within the same container
    ///
    /// The `Argument` and `Parameter` are both parameters of the given initializer.
    /// However, `Parameter` is a dependency registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter) -> Dependency
    ) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: Parameter.self)
            )
        }
        
        register(type: type, factory: factory)
    }
    
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has two parameters; the first is a dependency that is registered within the same container, the second is the variable argument
    ///
    /// The `Argument` and `Parameter` are both parameters of the given initializer.
    /// However, `Parameter` is a dependency registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter>(type: Dependency.Type = Dependency.self, argument: Argument.Type, initializer: @escaping (Parameter, Argument) -> Dependency) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}

// MARK: Default implementation for an initializer with a variable argument and 2 parameters
public extension DependencyWithArgumentAutoregistering {
    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first is the variable argument, the second and the third are dependencies that are registered within the same container
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Argument, Parameter1, Parameter2) -> Dependency
    ) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                argument,
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first and the third are dependencies that are registered within the same container, the second is the variable argument
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Argument, Parameter2) -> Dependency
    ) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter1.self),
                argument,
                resolver.resolve(type: Parameter2.self)
            )
        }
        
        register(type: type, factory: factory)
    }

    /// Autoregister a dependency with a variable argument and with the provided initializer method that has three parameters; the first and the second are dependencies that are registered within the same container, the third is the variable argument
    ///
    /// The `Argument`, `Parameter1` and `Parameter2` are parameters of the given initializer.
    /// However, `Parameter1` and `Parameter2` are dependencies registered in the same resolver (i.e. container),
    /// whereas `Argument` is not registered in the same container and it is typically variable,
    /// therefore, it needs to be handled separately
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register. Default value is implicitly inferred from the initializer return type
    ///   - argument: Type of the variable argument
    ///   - initializer: Initializer method of the `Dependency` that should be used to instantiate the dependency when it is being resolved from the container
    func autoregister<Dependency, Argument, Parameter1, Parameter2>(
        type: Dependency.Type = Dependency.self,
        argument: Argument.Type,
        initializer: @escaping (Parameter1, Parameter2, Argument) -> Dependency
    ) {
        let factory: FactoryWithOneArgument<Dependency, Argument> = { resolver, argument in
            initializer(
                resolver.resolve(type: Parameter1.self),
                resolver.resolve(type: Parameter2.self),
                argument
            )
        }
        
        register(type: type, factory: factory)
    }
}
