//
//  RegistrationIdentifier.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Maximum number of arguments supported for dependency resolution
private enum Constant {
    static let maximumArgumentCount = 3
}

/// Object that uniquely identifies a registered dependency
struct RegistrationIdentifier: Sendable {
    let typeIdentifier: ObjectIdentifier
    let argumentIdentifiers: [ObjectIdentifier]

    /// Initializer using parameter packs for any number of argument types
    ///
    /// - Parameters:
    ///   - type: Type of the dependency
    ///   - argumentTypes: Variadic argument types using parameter packs. Only 1-3 arguments are supported. Entering more arguments will cause error in runtime.
    init<Dependency, each Argument>(type: Dependency.Type, argumentTypes _: repeat (each Argument).Type) {
        typeIdentifier = ObjectIdentifier(type)

        var identifiers: [ObjectIdentifier] = []
        repeat identifiers.append(ObjectIdentifier((each Argument).self))

        precondition(
            identifiers.count <= Constant.maximumArgumentCount,
            "Maximum number of arguments is \(Constant.maximumArgumentCount). Got \(identifiers.count)."
        )

        argumentIdentifiers = identifiers
    }

    /// Convenience initializer for dependencies without arguments
    init<Dependency>(type: Dependency.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifiers = []
    }
}

// MARK: Hashable
extension RegistrationIdentifier: Hashable {}

// MARK: Debug information
extension RegistrationIdentifier: CustomStringConvertible {
    var description: String {
        let argumentsDescription: String = if argumentIdentifiers.isEmpty {
            "nil"
        } else {
            argumentIdentifiers.map(\.debugDescription).joined(separator: ", ")
        }
        return """
        Type: \(typeIdentifier.debugDescription)
        Arguments: \(argumentsDescription)
        """
    }
}
