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
    private let identifier: String?

    public lazy var wrappedValue: T = {
        container.resolve(with: identifier)
    }()

    public init(container: Container = .shared, identifier: String? = nil) {
        self.container = container
        self.identifier = nil
    }
}
