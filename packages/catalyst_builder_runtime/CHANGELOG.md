## 7.0.0-beta.1

### Breaking

- The package has been renamed from `catalyst_builder_contracts` to `catalyst_builder_runtime`.
  Update your imports to `package:catalyst_builder_runtime/catalyst_builder_runtime.dart` and add
  it as a regular dependency:

  ```yaml
  dependencies:
    catalyst_builder_runtime: ^7.0.0
  ```
- The `ServiceContainer` has been moved from `catalyst_builder` into this package. Import it from
  `catalyst_builder_runtime` instead of `catalyst_builder`.
- `ServiceDescriptor` factories now receive the resolving container:
  `ServiceDescriptor(const Service(), (c) => MyService(c.resolve<Foo>()))`.
  `ServiceDescriptor.produce()` became `produce(AbstractServiceContainer container)`.
- `ServiceContainerPlugin.provideKnownServices()` no longer receives the container as a
  parameter.
- `enhance()` now creates a child container linked to its parent instead of copying all
  registrations. Singletons are always built and cached by the container that registered
  them: a root singleton can no longer see child-only dependencies (it now throws
  `DependencyNotFoundException` like on the root). Services registered in a child stay
  invisible to the root.

### Fixes

- `ServiceNotFoundException` thrown by `resolve` now reports the runtime type that was
  passed as argument instead of the static generic type.

