# Dependency Injection

[![build](https://github.com/strvcom/ios-dependency-injection/actions/workflows/integrations.yml/badge.svg)](https://github.com/strvcom/ios-dependency-injection/actions/workflows/integrations.yml/badge.svg)
[![Coverage](https://img.shields.io/badge/Coverage-100%-darkgreen?style=flat-square)](https://img.shields.io/badge/Coverage-100%-darkgreen?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_iPadOS_macOS_tvOS_watchOS-lightgrey?style=flat-square)](https://img.shields.io/badge/Platforms-iOS_iPadOS_macOS_tvOS_watchOS-lightgrey?style=flat-square)
[![Swift](https://img.shields.io/badge/Swift-5.3_5.4_5.5-blue?style=flat-square)](https://img.shields.io/badge/Swift-5.3_5.4_5.5-blue?style=flat-square)

The lightweight library for dependency injection in Swift

## Requirements

- iOS/iPadOS 13.0+, macOS 10.15+, watchOS 6.0+, tvOS 13.0+
- Xcode 11+
- Swift 5.3+

## Installation

You can install the library with [Swift Package Manager](https://swift.org/package-manager/). Once you have your Swift package set up, adding Dependency Injection as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/strvcom/ios-dependency-injection.git", .upToNextMajor(from: "1.0.0"))
]
```

## Dependency Injection

If you are new to the concept of Dependency Injection, you can check [Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection) for a general introduction and brief overview.

## Usage

A container is a key component of Dependency Injection. A container manages dependencies of your codebase. First, you register your dependencies within the container identified by either their types, or protocols or classes they conform to or inherit from respectively. Then, you use the container to get, i.e. resolve instances of the registered dependencies. The class [Container](Sources/Container/Container.swift) represents the Dependency Injection container.

Other terminology that might be useful:

- **Factory** - A function or closure instantiating a dependency
- **Scope** - A scope of a registered dependency can be either `new` or `shared`. When a dependendency is registered with `new` scope, a new instance of the dependency is created each time the dependency is resolved from the container. When a dependendency is registered with `shared` scope, a new instance of the dependency is created only the first time it is resolved from the container. The created instance is cached and it is returned for all upcoming resolution requests i.e. it is a singleton
- **Registration with an argument** - All dependencies must be initialized and their initializers often have parameters. Typically, the objects that are passed as the input parameters are resolved from the same container. But you might want to have a registered dependency which requires a parameter in its initializer that can't be registered in the container. In such case, you register the dependency with a variable argument and you specify a value of the argument when the dependency is being resolved; the value is passed as an input parameter to the dependency factory.

### Registration

A dependency is registered with the `register` method of the container. A dependency is registered with a type that is either its own type, or a protocol or a class that the dependency conform to or inherit from respectively. Next, a scope of registration must be specified (see the terminology above). Finally, a factory closure or function that returns an instance of the dependency must be provided.

It can look like this:
```swift
let container = Container()
container.register(type: Dependency.self, in: .shared) { container in
  Dependency(
    manager: container.resolve(type: Manager.self)
  )
}
```
We can also use the fact that the type is by default inferred from the factory return type and `shared` is the default scope so we can simplify the above snippet into this:
```swift
let container = Container()
container.register { container in
  Dependency(
    manager: container.resolve(type: Manager.self)
  )
}
```
Moreover, if we want to register a shared dependency that has no sub-dependencies from the container we can use an overloaded registration method with an autoclosure like this:
```swift
let container = Container()
container.register(dependency: SimpleDependency())
```

### Registration with an argument

See the terminology above to understand what we mean by the registration with an argument.

_DISCUSSION: The registration with an argument doesn't have any scope parameter and it is for a reason. The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined. Should the argument conform to `Equatable` to compare the arguments to tell whether a shared instance with a given argument was already resolved? Shared instances are typically not dependent on variable input parameters by definition. If you need to support this usecase, please, keep references to the variable singletons outside of the container._

Let's assume that our dependency from above needs also an integer that is determined right before the dependency is supposed to be resolved from the container. There is no point in registering the integer as a dependency in the container, moreover, we typically don't even want to register simple types like integers. For such case, we have the registration with an argument:
```swift
let container = Container()
container.register { container, number in
  Dependency(
    integer: number,
    manager: container.resolve(type: Manager.self)
  )
}
```

### Autoregistration

Let's have look at an example from above:
```swift
let container = Container()
container.register { container in
  Dependency(
    manager: container.resolve(type: Manager.self)
  )
}
```
In the factory closure, we typically just call the dependency initializer and we resolve its input parameters from the container. You can get rid of this duplicated boiler-plate by using `autoregister` method where you specify just the initializer that should be used to initialize the dependency, instead of writing the same factories over and over again. The above example then looks like this:
```swift
let container = Container()
container.autoregister(initializer: Dependency.init)
```
Similarly, we can use autoregistration with an argument and replace this:
```swift
let container = Container()
container.register { container, number in
  Dependency(
    integer: number,
    manager: container.resolve(type: Manager.self)
  )
}
```
With the following:
```swift
let container = Container()
container.autoregister(argument: Int.self)(initializer: Dependency.init)
```

### Resolution

Dependency resolution is very straightforward. You can use either container's `tryResolve` method that throws an error when something goes wrong, or simply `resolve` which returns the resolved non-optional dependency but is anything goes wrong, your app will crash.

You can resolve a registered dependency like this:
```swift
let container = Container()
container.register { container in
  Dependency(
    manager: container.resolve(type: Manager.self)
  )
}

let dependency = container.resolve(type: Dependency.self)
let dependency2: Dependency = container.resolve()
```

Or a dependendency registered with an argument like this:
```swift
let container = Container()
container.register { container, number in
  Dependency(
    integer: number,
    manager: container.resolve(type: Manager.self)
  )
}

let dependency = container.resolve(type: Dependency.self, argument: 42)
let dependency2: Dependency = container.resolve(argument: 42)
```

## Roadmap

- [x] Register and resolve a shared instance
- [x] Register and resolve a new instance
- [x] Register an instance with an identifier
- [x] Register an instance with an argument
- [x] Convenient property wrapper
- [x] Autoregister
- [ ] SPM package
- [ ] Register an instance with multiple arguments
- [ ] Container hierarchy
- [ ] Thread-safety
- [ ] Detect circular dependencies
