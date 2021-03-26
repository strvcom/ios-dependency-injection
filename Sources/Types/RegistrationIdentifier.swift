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
    
    init<T>(type: T.Type, identifier: String?) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.customIdentifier = identifier
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
