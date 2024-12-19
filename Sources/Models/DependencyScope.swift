//
//  DependencyScope.swift
//  
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Scope of a dependency
public enum DependencyScope: Sendable {
    /// A new instance of the dependency is created each time the dependency is resolved from the container.
    case new
    
    /// A new instance of the dependency is created only the first time it is resolved from the container. The created instance is cached and it is returned for all subsequent resolution requests, i.e. it is a singleton
    case shared
}
