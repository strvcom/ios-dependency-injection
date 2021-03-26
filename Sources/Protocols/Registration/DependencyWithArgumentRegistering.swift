//
//  DependencyWithArgumentRegistering.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public protocol DependencyWithArgumentRegistering: DependencyRegistering {
    typealias ResolverWithArgument<T, Argument> = (DependencyWithArgumentResolving, Argument) -> T
    
    func register<T, Argument>(type: T.Type, with identifier: String?, factory: @escaping ResolverWithArgument<T, Argument>)
}

// MARK: Overloaded factory methods
public extension DependencyWithArgumentRegistering {
    func register<T, Argument>(with identifier: String?, factory: @escaping ResolverWithArgument<T, Argument>) {
        register(type: T.self, with: identifier, factory: factory)
    }

    func register<T, Argument>(type: T.Type, factory: @escaping ResolverWithArgument<T, Argument>) {
        register(type: type, with: nil, factory: factory)
    }
    
    func register<T, Argument>(factory: @escaping ResolverWithArgument<T, Argument>) {
        register(type: T.self, with: nil, factory: factory)
    }
}
