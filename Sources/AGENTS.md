# Sources/AGENTS.md

Scoped to `Sources/`. General workflow is in [../CONTRIBUTING.md](../CONTRIBUTING.md), which also
carries the full list of container invariants; the three most load-bearing are repeated here because
they are the ones an edit in this tree is most likely to break.

- **`Container` is not thread-safe, `resolve` traps, and omitting `in:` registers `.new`.** The class
  is `@unchecked Sendable` but mutates `registrations`/`sharedInstances` without a lock. `resolve` is
  `try! tryResolve`, so an unregistered type kills the process. `register { ... }` with no scope binds
  the variadic-argument overload, which hard-codes `scope: .new`. Changing any of these three changes
  the public contract — see ../CONTRIBUTING.md before touching them.

- **Sync and async are parallel implementations that must stay in step.** The pairs are
  `Container`/`AsyncContainer`, `Registration`/`AsyncRegistration`, `DependencyResolving`/
  `AsyncDependencyResolving`, `DependencyRegistering`/`AsyncDependencyRegistering`, and
  `ModuleRegistration`/`AsyncModuleRegistration`. A behaviour change on one side almost always needs
  the mirrored change on the other. The async side additionally requires `Sendable` bounds on
  `Dependency` and on each `Argument`, and its factories are `@Sendable` and `async`. Note the one
  deliberate asymmetry: `DependencyAutoregistering` has no async counterpart.

- **Keep `Container`'s `register`/`tryResolve` methods `open` and in the class body.** They were
  moved out of extensions in 1.0.3 specifically so subclasses can override them. Methods declared in
  a class extension are statically dispatched, so relocating one there would compile cleanly while
  silently ignoring every downstream override.

- **The target enables the `StrictConcurrency` upcoming feature** (see `../Package.swift`). New code
  must be strict-concurrency clean.

- **`APPLICATION_EXTENSION_API_ONLY` is a convention here, not an enforced check.** It was added in
  1.0.3 to silence app-extension warnings, but it cannot do that: `Package.swift` passes it through
  `.define(...)`, which is a Swift compilation condition (`-D`), not the Xcode
  `APPLICATION_EXTENSION_API_ONLY = YES` build setting; the Xcode project likewise only puts it in
  `SWIFT_ACTIVE_COMPILATION_CONDITIONS`, and no file guards on it with `#if`. Nothing in this package
  will stop you calling API that is unavailable to app extensions — it breaks only when a consumer
  builds an extension target. Real enforcement would need `unsafeFlags(["-application-extension"])`,
  which SwiftPM forbids in a package consumed by version, so the convention is all there is: avoid
  extension-unavailable API by hand.

- **The force casts and force tries here are deliberate, and SwiftLint flags them anyway.** The `as!`
  in `Container.getDependency`, and both cast sites in `AsyncContainer.getDependency` (the shared-task
  path and the main path), are load-bearing: `Registration.factory` erases its return type to `Any` so
  heterogeneous registrations can share one dictionary, and the cast is guaranteed by construction
  because a `Registration` can only be built from a factory of the matching type. The `try!` in both
  `resolve` overloads of `DependencyResolving` and `AsyncDependencyResolving` is the documented
  trapping behaviour that distinguishes `resolve` from `tryResolve`. SwiftLint reports every one of
  these as a `force_cast`/`force_try` violation; they are pre-existing and not enforced by CI. Do not
  "fix" them — softening either one would hide registration bugs or silently change the public
  contract.

- **`RegistrationIdentifierConstant.maximumArgumentCount` is the single source of the argument cap.**
  It is read by the guard in both containers' `tryResolve(type:arguments:)`. Changing the limit means
  changing that constant, not the call sites.

- **Doc comments are duplicated between sync and async declarations on purpose** — DocC renders each
  symbol independently. When you correct one, correct its twin.

- **Everything here ships as public API**, and it is the surface [../AGENTS.md](../AGENTS.md)
  documents for app developers. A signature change needs a `CHANGELOG.md` entry and usually an
  `../AGENTS.md` and `../README.md` update in the same pull request.
