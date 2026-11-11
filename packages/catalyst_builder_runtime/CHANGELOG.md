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

