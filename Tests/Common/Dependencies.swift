//
//  Dependencies.swift
//  
//
//  Created by Jan Schwarz on 15.12.2021.
//

import Foundation

protocol DIProtocol: Sendable {}

struct StructureDependency: Equatable, DIProtocol {
    static let `default` = StructureDependency(property1: "test")
    
    let property1: String
}

final class SimpleDependency: DIProtocol {}

final class DependencyWithValueTypeParameter: Sendable {
    let subDependency: StructureDependency
    
    init(subDependency: StructureDependency = .default) {
        self.subDependency = subDependency
    }
}

final class DependencyWithParameter: Sendable {
    let subDependency: SimpleDependency
    
    init(subDependency: SimpleDependency) {
        self.subDependency = subDependency
    }
}

final class DependencyWithParameter2: Sendable {
    let subDependency1: SimpleDependency
    let subDependency2: DependencyWithValueTypeParameter

    init(subDependency1: SimpleDependency, subDependency2: DependencyWithValueTypeParameter) {
        self.subDependency1 = subDependency1
        self.subDependency2 = subDependency2
    }
}

final class DependencyWithParameter3: Sendable {
    let subDependency1: SimpleDependency
    let subDependency2: DependencyWithValueTypeParameter
    let subDependency3: DependencyWithParameter

    init(
        subDependency1: SimpleDependency,
        subDependency2: DependencyWithValueTypeParameter,
        subDependency3: DependencyWithParameter
    ) {
        self.subDependency1 = subDependency1
        self.subDependency2 = subDependency2
        self.subDependency3 = subDependency3
    }
}

final class DependencyWithParameter4: Sendable {
    let subDependency1: SimpleDependency
    let subDependency2: DependencyWithValueTypeParameter
    let subDependency3: DependencyWithParameter
    let subDependency4: DependencyWithParameter2

    init(
        subDependency1: SimpleDependency,
        subDependency2: DependencyWithValueTypeParameter,
        subDependency3: DependencyWithParameter,
        subDependency4: DependencyWithParameter2
    ) {
        self.subDependency1 = subDependency1
        self.subDependency2 = subDependency2
        self.subDependency3 = subDependency3
        self.subDependency4 = subDependency4
    }
}

final class DependencyWithParameter5: Sendable {
    let subDependency1: SimpleDependency
    let subDependency2: DependencyWithValueTypeParameter
    let subDependency3: DependencyWithParameter
    let subDependency4: DependencyWithParameter2
    let subDependency5: DependencyWithParameter3

    init(
        subDependency1: SimpleDependency,
        subDependency2: DependencyWithValueTypeParameter,
        subDependency3: DependencyWithParameter,
        subDependency4: DependencyWithParameter2,
        subDependency5: DependencyWithParameter3
    ) {
        self.subDependency1 = subDependency1
        self.subDependency2 = subDependency2
        self.subDependency3 = subDependency3
        self.subDependency4 = subDependency4
        self.subDependency5 = subDependency5
    }
}
