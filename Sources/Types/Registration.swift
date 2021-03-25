//
//  Registration.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct Registration {
    let identifier: RegistrationIdentfier
    let scope: DependencyScope
    let factory: (DependencyResolving) -> Any
    
    init<T>(type: T.Type, scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        self.identifier = RegistrationIdentfier(type: type)
        self.scope = scope
        self.factory = factory
    }
}
