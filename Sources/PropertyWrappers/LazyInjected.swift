//
//  LazyInjected.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// Convenient property wrapper that automatically resolves a dependency from the container to the wrapped value based on the wrapped value's type
///
/// By default, the property wrapper uses the ``Container.shared`` singleton
///
/// The dependency is resolved when the wrapped value is accessed for the first time
///
/// The property wrapper is a class in order to be able to modify the wrapped value when the dependency is resolved, regardless of the type of the object where the property wrapper is stored
@propertyWrapper public final class LazyInjected<Dependency> {
    private let container: Container

    public lazy var wrappedValue: Dependency = container.resolve(type: Dependency.self)

    /// Property wrapper initializer
    /// - Parameter container: Container that will be used to resolve the dependency
    public init(from container: Container = .shared) {
        self.container = container
    }
}
