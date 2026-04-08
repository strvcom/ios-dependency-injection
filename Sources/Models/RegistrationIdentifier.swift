//
//  RegistrationIdentifier.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Maximum number of arguments supported for dependency resolution (enforced at resolve time)
enum RegistrationIdentifierConstant {
    static let maximumArgumentCount = 3
}

/// Object that uniquely identifies a registered dependency
struct RegistrationIdentifier: Sendable {
    let typeIdentifier: ObjectIdentifier
    let argumentIdentifiers: [ObjectIdentifier]
    let typeDescription: String
    let argumentTypeDescriptions: [String]

    /// Number of argument types (used to enforce maximum at resolve time)
    var argumentCount: Int { argumentIdentifiers.count }

    /// Initializer using parameter packs for any number of argument types.
    /// Registration with more than 3 arguments is allowed; resolution with more than 3 arguments will throw.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency
    ///   - argumentTypes: Variadic argument types using parameter packs. Only 1-3 arguments are supported. Entering more arguments will cause error in runtime.
    init<Dependency, each Argument>(type: Dependency.Type, argumentTypes _: repeat (each Argument).Type) {
        typeIdentifier = ObjectIdentifier(type)
        typeDescription = String(reflecting: type)

        var identifiers: [ObjectIdentifier] = []
        var descriptions: [String] = []
        repeat identifiers.append(ObjectIdentifier((each Argument).self))
        repeat descriptions.append(String(reflecting: (each Argument).self))

        argumentIdentifiers = identifiers
        argumentTypeDescriptions = descriptions
    }

    /// Convenience initializer for dependencies without arguments
    init<Dependency>(type: Dependency.Type) {
        typeIdentifier = ObjectIdentifier(type)
        typeDescription = String(reflecting: type)
        argumentIdentifiers = []
        argumentTypeDescriptions = []
    }
}

// MARK: Hashable
extension RegistrationIdentifier: Hashable {}

// MARK: Debug information
extension RegistrationIdentifier: CustomStringConvertible {
    var description: String {
        if argumentTypeDescriptions.isEmpty {
            typeDescription
        } else {
            "\(typeDescription)(\(argumentTypeDescriptions.joined(separator: ", ")))"
        }
    }
}

func runtimeTypeDescription(of value: Any?) -> String {
    guard let value else {
        return "nil"
    }

    return String(reflecting: Swift.type(of: value))
}
