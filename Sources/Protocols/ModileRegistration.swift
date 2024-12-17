//
//  ModileRegistration.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

public protocol ModuleRegistration {
    static func registerDependencies(in container: AsyncContainer) async
}
