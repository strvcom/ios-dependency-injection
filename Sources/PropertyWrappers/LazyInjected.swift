//
//  File.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

@propertyWrapper
public final class LazyInjected<Dependency> {
    private let container: Container

    public lazy var wrappedValue: Dependency = {
        container.resolve(type: Dependency.self)
    }()

    public init(container: Container = .shared) {
        self.container = container
    }
}
