//
//  File.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

@propertyWrapper
public final class LazyInjected<T> {
    private let container: Container

    public lazy var wrappedValue: T = {
        container.resolve(type: T.self)
    }()

    public init(container: Container = .shared) {
        self.container = container
    }
}
