# Tests/AGENTS.md

Scoped to `Tests/`. General workflow and testing expectations are in [../CONTRIBUTING.md](../CONTRIBUTING.md).

- **These are Swift Testing suites, not XCTest** — `@Suite`, `@Test`, `#expect`, and `Issue.record`
  for the failure paths. Suites run in parallel by default, which matters for the next point.

- **A test that registers into `Container.shared` or `AsyncContainer.shared` must `clean()` before it
  returns.** Those singletons are process-global, so a leftover registration leaks into every other
  suite running in the same process and produces failures far from the cause.
  `PropertyWrappers/PropertyWrapperTests.swift` shows the pattern. Prefer a local `Container()`
  unless the test is specifically about singleton behaviour.

- **Declare tags in `Common/TestTags.swift`, not inline.** Every suite carries tags from that file
  (`.sync`/`.async` plus `.base`, `.arguments`, `.complex`, `.autoregistration`,
  `.propertyWrappers`); they are how suites are selected when running a subset. Add a new `@Tag`
  there when you need one.

- **Reuse the fixture types in `Common/Dependencies.swift`** rather than declaring new ones per
  suite. Anything used with `AsyncContainer` must be `Sendable`.

- **`Container/Sync` and `Container/Async` are deliberate mirrors.** Adding a case to one usually
  means adding the equivalent to the other, with the async version awaiting registration and
  resolution.

- **`.swiftlint.yml` excludes `Tests`, so lint rules do not apply here.** Force unwraps, magic
  numbers, and long suites are expected in test code — do not "fix" them to satisfy rules that are
  not enforced on this directory.
