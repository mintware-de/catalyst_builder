## 2.3.1

Changes:
- Dependencies updated
  - `analyzer`: `>=3.2.0 <5.0.0` -> `>=4.3.0 <5.0.0`
  - `build_runner`: `^2.0.4` -> `^2.2.0` 
- Using `enclosingElement2` instead of `enclosingElement` (pub.dev score)
- Added ignore rules for generated files
  - `implementation_imports`
  - `no_leading_underscores_for_library_prefixes`

## 2.3.0
Features:
- Added `tags` to the `Service` annotation 
- Added `ServiceProvider.resolveByTag(#tag)` to resolve a list of services by a tag.

Take a look in the [README.md](./README.md) for example usage.

Changes:
- Dependencies updated
  - glob: `^2.0.1` -> `^2.1.0`
- Dev Dependencies updated
  - lints: `^1.0.1` -> `^2.0.0`

Internal:
- `TryCatchBuilder` removed.

## 2.2.3

Changes:
- Added shields to the README.md
- Added more unit tests and increased the code coverage. [PR#8](https://github.com/mintware-de/catalyst_builder/pull/8)

Bugfixes:
- Add the parameters of the parent service provider to the enhanced service provider.
  [PR#7](https://github.com/mintware-de/catalyst_builder/pull/7)

## 2.2.2

Changes:
- README.md updated

## 2.2.1

Changes:
- Dependencies updated
  - `analyzer`: `^3.2.0` -> `>=3.2.0 <5.0.0`
  - `test`: `^1.20.1` -> `any`
  - `source_gen` -> removed

## 2.2.0

Features
- Added the `EnhanceableProvider` class and implemented it in the generated ServiceProvider.
  This class allows you to create sub-providers. [PR#5](https://github.com/mintware-de/catalyst_builder/pull/5)

## 2.1.0

Features
- Added the `ServiceRegistry` class and implemented it in the generated ServiceProvider.
  This class allows you to register services at runtime. [PR#4](https://github.com/mintware-de/catalyst_builder/pull/4)

Changes:
- Optimized the code generation [PR#3](https://github.com/mintware-de/catalyst_builder/pull/3)

## 2.0.0

Upgraded the `analyzer` and the `test` package to support Flutter 2.10.

## 1.3.3

Downgraded the `analyzer` package to ensure compatibility to the `test` package.

## 1.3.2

Fixed pub.dev score issues.

- upgraded the `analyzer` package
- removed the `pedantic` dev-package
- removed an unused import in the `extracted_service.dart`

## 1.3.1

Project code moved to GitHub. Updated the pubspec.yaml

## 1.3.0

Features:
- Added `ServiceProvider.has<T>([Type? t])` to check if a service is known.

Changes
- Updated the dependencies
  - code_builder `^4.0.0` -> `^4.1.0`
  - build `^2.0.1` -> `^2.1.0`
  - analyzer `^1.7.1` -> `^2.2.0`
  - build_runner_core `^7.0.0` -> `^7.1.0`

## 1.2.0

Added a `@ServiceMap` annotation.

## 1.1.1

Changed the preflight output extension to avoid conflicting outputs.

## 1.1.0

Added a `includePackageDependencies` option to the build.yaml.

## 1.0.2

Dependencies downgraded

## 1.0.1

Publisher fixed

## 1.0.0

**First stable release** ????

- Code generator organized

## 0.0.6

- Added unit and integration tests
- Formatting fixed

## 0.0.5

- `ServiceProvider.boot()` added
- `@Preload` annotation added

## 0.0.4

- Formatting fixed

## 0.0.3

- Packages updated to ensure null-safety

## 0.0.2

- Added better exceptions
- Added a `Parameter` annotation which can be used to override the name that is used for resolving a parameter.

## 0.0.1

- Initial version.
