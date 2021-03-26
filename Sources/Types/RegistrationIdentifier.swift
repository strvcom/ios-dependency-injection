//
//  RegistrationIdentfier.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct RegistrationIdentfier {
    let typeIdentifier: ObjectIdentifier
    let customIdentifier: String?
    let argumentIdentifiers: ObjectIdentifier?
    
    init<T, Argument>(type: T.Type, identifier: String?, argument: Argument.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.customIdentifier = identifier
        self.argumentIdentifiers = ObjectIdentifier(type)
    }
    
    init<T>(type: T.Type, identifier: String?) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.customIdentifier = identifier
        self.argumentIdentifiers = nil
    }
}

// MARK: Hashable
extension RegistrationIdentfier: Hashable {}

// MARK: Debug information
extension RegistrationIdentfier: CustomStringConvertible {
    var description: String {
        """
        Type: \(typeIdentifier.debugDescription)
        Identifier: \(customIdentifier ?? "nil")
        """
    }
}
