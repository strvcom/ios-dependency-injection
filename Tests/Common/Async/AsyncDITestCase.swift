//
//  AsyncDITestCase.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import XCTest

class AsyncDITestCase: XCTestCase {
    var container: AsyncContainer!

    override func setUp() {
        super.setUp()

        container = AsyncContainer()
    }

    override func tearDown() {
        container = nil

        super.tearDown()
    }
}
