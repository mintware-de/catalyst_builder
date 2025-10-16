## 6.0.0-rc.1
 
Removed unused packages
- `path`
- `yaml`

Updated package version
- `dart_style: ^3.1.2`

## 6.0.0-dev.3
 
Fix downgrade issues by updating package version
```yaml
analyzer: ^8.1.0
lints: '>=2.0.0'
```

## 6.0.0-dev.2
 
**BREAKING CHANGE**: Upgraded the versions of this packages:
```yaml
build: ^4.0.0
analyzer: ^8.0.0
```

## 6.0.0-dev.1

To support the latest version of `build` and `analyzer` we
switched to the new [element model api](https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/doc/element_model_migration_guide.md).

This causes a **BREAKING CHANGE** since the required versions of the packages where updated to 
```yaml
build: ^3.0.0
analyzer: '>=7.4.0 <9.0.0'
```

## 5.0.0

I'm proud to release v5.0.0 🎉

This release contains a lot of rework in the underlying engine.

This is a list of the largest changes between v4.3.2 and v5.0.0

- New plugin based architecture
- The `ServiceContainer` (formerly `ServiceProvider`) is no longer generated code. Instead, I created a
  `ServiceContainer` implementation that uses Plugins which are generated.
- Services from dependencies are no longer included. This improves the build speed and reliability of generated code.
  Services from dependencies must be deployed as plugins. This gives you more control over what is registered in your
  container.
- Aligned naming: In the previous versions, we mixed the terms `provider` and `container`. Starting with this version
  we will use only `container`.

For upgrade guidance check the "[Upgrade from v4 to v5](https://github.com/mintware-de/catalyst_builder/wiki/v5)" Guide

## 5.0.0-rc.1

### Breaking Changes

- Removed the generation of the service container. Check
  the [GenerateServiceProvider](https://github.com/mintware-de/catalyst_builder/wiki/v5#generateserviceprovider) section
  for upgrade guidance.

## 5.0.0-dev.2

### Changes

- Removed export of `catalyst_builder_annotations`.

## 5.0.0-dev.1

We need a total makeover of the underlying architecture.
Services from packages you depend on are no longer resolved automatically!

More background information is available in the [Wiki](https://github.com/mintware-de/catalyst_builder/wiki/v5)

### Changes

- `includePackageDependencies` was removed

## 4.3.2

### Changes

- Updated the README and added screenshots

## 4.3.1

### Changes

- Removed verbose logging
- Removed the caching system

## 4.3.0

### Changes

#### Migrated the ServiceProviderBuilder to post_process_builders

Since the ServiceProviderBuilder does not rely on the real outputs of the previous builders but the cache files,
this is a much better solution since a PostProcessBuilders does not process all .dart files.

### Fixes

#### Skip unprocessable files

This will fix the following error when using catalyst_builder with Flutter:

```plain
[SEVERE] catalyst_builder:preflight on package:sky_engine/html/html_dart2js.dart:

This builder requires Dart inputs without syntax errors.
...
```

## 4.2.1

### Fixes

- Fixed the dependency detection in the preflight builder.

## 4.2.0

### Changes

#### Project separation

To improve the maintainability of your projects, we decided to separate the less frequently changing parts - such as
annotations, abstractions like the base class for the ServiceProvider, and exceptions (`catalyst_builder_contracts`) -
from the more frequently changing parts, like the implementation of the builder itself (`catalyst_builder`).

This means that a breaking change in the `catalyst_builder` package does not force you to update projects where you only
use the annotations.

## 4.1.0

### Features

#### Cache location

You're now able to set a custom cache location by setting `catalyst_builder: { cacheDir: 'a/cache/path' }` property in
the pubspec.yaml

Take a look in [pubspec.yaml](example/pubspec.yaml) for an example.

### Internal

- The `CacheHelper` is no longer static.

## 4.0.0

This major update has breaking changes.
Check the [UPGRADE.md](UPGRADE.md) for guidance.

### Features

#### Caching system

This release contains a new caching system for intermediates. Those are stored in a `.catalyst_builder_cache` directory.
Don't forget to exclude this from the VCS.

### Changes

#### Dependency updates

- `build_runner_core`: Removed

### Breaking Changes:

#### Dart SDK

Bump the minimum Dart SDK version to 3.5.0

#### Dependency updates

- `dart_style`: `^2.0.1` => `^3.0.1`
- `analyzer`: `'>=5.2.0 <7.0.0'` => `'>=5.2.0 <8.0.0'`

#### Annotations

Removed the deprecated `@Parameter` annotation. Use `@Inject` instead.

#### Build customization

Moved the `providerClassName` and `includePackageDependencies` option to the `@GenerateServiceProvider` annotation

## 3.6.0

### Fixed updating the generated provider file

In this release we hopefully fixed the old problem with outdated `*.catalyst_builder.g.dart` files.

#### Cause

The ServiceProviderBuilder did not emit an updated version since the `@GenerateServiceProvider` annotation
doesn't exist in the most files.

#### Solution

We added a new `generatedProviderFile` option to the preflightBuilder configuration. You need to put the relative path
to the generated provider file (`*.catalyst_builder.g.dart`) in this option.
The PreflightBuilder will automatically delete the file if it exists. This lead to a full regeneration of the service
provider file. 🙌

## 3.5.2

### Fix downgrade error

In version 5.0.0 of the `analyzer` Package was `DartType.element` removed.
It was added again in 5.2.0 so we updated the version constraint to `>=5.2.0 <7.0.0` to fix that downgrade error.

## 3.5.1

### Singleton instances on enhanced providers

Previously each ServiceProvider had a map of service instances. If a singleton was created, the provider stored the
instance in the map and returned the instance the next time it is requested.

If you're working with enhanced providers (`ServiceProvider.enhance`), the singletons created in the EnhancedProvider
wasn't stored in the root provider which causes that a singleton will be created again if it's resolved in the root
provider.

To solve this problem, the instances of the map is now a reference to the original instances map of the parent provider.

### Dependency updates

Moved the lints to dev_dependencies and set the version constraint to any

## 3.5.0

Updated the version constraint of the analyzer package.

## 3.4.0

Features:

- Added an example for working with relative
  dependencies. [PR#19](https://github.com/mintware-de/catalyst_builder/pull/19)

Changes:

- The preflight builder will no more emit empty files. This should increase the build
  performance. [PR#18](https://github.com/mintware-de/catalyst_builder/pull/18)

## 3.3.1

Fixes:

- Fixed the enhance method. [PR#16](https://github.com/mintware-de/catalyst_builder/pull/16)

## 3.3.0

Features:

- Added stricter rules to analysis_options.yaml
    - Added type castings to the generated service provider.

## 3.2.3

Fixes:

- Fixed the enhance method and overtake the expose map and the known services map.

## 3.2.2

Fixes:

- Fixed the type inference when enhancing the ServiceProvider.

## 3.2.1

Fixes:

- Fixed the generation for libraries (working with `part` and `part of`).
- Fixed the extraction of services for packages without the `GenerateServiceProvider` annotation.

## 3.2.0

Features:

- Introducing the new `@Inject` annotation. This annotation works like the `@Parameter` Annotation but is more flexible.
  You can use it to inject a list of tagged services and also to inject parameters. The example code contains a
  example for this feature.

Deprecations:

- The `@Parameter` annotation was marked as deprecated and will be removed in the next major release.  
  See [UPGRADE.md](UPGRADE.md) for upgrade instructions.

Changes:

- Updated the minimum `analyzer` version to `^5.0.0`

Internal:

- Updated the usages of deprecated properties. Using
    - `element` instead of `element2`
    - `enclosingElement` instead of `enclosingElement3`
- Preflight logic refactored

## 3.1.0

Maintenance Release

- Replaced a deprecated function call (assignVar)

## 3.0.0

Features:

- Added the `GenerateServiceProvider` annotation

Changes:

- Updated the minimum Dart SDK version to `2.17.0`

Breaking Changes:

- `build.yaml`
    - Removed the option `outputName`
      This change was necessary since the build_runner does not recognize changes correctly with runtime file names.
    - Removed the option `preflightExtension`.

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

**First stable release** 🎉

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
