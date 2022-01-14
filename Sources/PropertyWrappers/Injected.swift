//
//  Injected.swift
//  
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// Convenient property wrapper that automatically resolves a dependency from the container to the wrapped value based on the wrapped value's type
///
/// By default, the property wrapper uses the `Container.shared` singleton
/// 
/// The dependency is resolved right on the property wrapper instantiation
@propertyWrapper public struct Injected<Dependency> {
    public let wrappedValue: Dependency
    
    /// Property wrapper initializer
    /// - Parameter container: `Container` that will be used to resolve the dependency
    public init(from container: Container = .shared) {
        wrappedValue = container.resolve(type: Dependency.self)
    }
}
