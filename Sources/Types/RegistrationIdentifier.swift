//
//  RegistrationIdentfier.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct RegistrationIdentfier {
    let identifier: ObjectIdentifier
    
    init<T>(type: T.Type) {
        self.identifier = ObjectIdentifier(type)
    }
}

// MARK: Hashable
extension RegistrationIdentfier: Hashable {}

// MARK: Debug information
extension RegistrationIdentfier: CustomStringConvertible {
    var description: String {
        identifier.debugDescription
    }
}
