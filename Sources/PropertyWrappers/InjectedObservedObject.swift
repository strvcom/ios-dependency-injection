import SwiftUI

@propertyWrapper public struct InjectedObservedObject<Object>: DynamicProperty
where Object: ObservableObject {
    @ObservedObject public var wrappedValue: Object = Container.shared.resolve()

    public var projectedValue: ObservedObject<Object>.Wrapper {
        $wrappedValue
    }

    public init(from container: Container = .shared) {
        wrappedValue = container.resolve(type: Object.self)
    }
}
