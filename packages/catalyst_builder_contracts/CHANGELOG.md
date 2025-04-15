## 2.0.0-rc.1

### Breaking Changes

- Removed `GenerateServiceProvider` annotation
- Renamed `GenerateServiceProviderPlugin` to `GenerateServiceContainerPlugin`
- Renamed `ProviderAlreadyBootedException` to `ContainerAlreadyBootedException`
- Renamed `ProviderNotBootedException` to `ContainerNotBootedException`
- Renamed `ServiceProvider` to `AbstractServiceContainer`
- Renamed `ServiceProviderPlugin` to `ServiceContainerPlugin`

## 2.0.0-dev.2

### Breaking Changes
- Changed `ServiceProvider` and `ServiceRegistry` to interfaces
- Removed `EnhanceableProvider` and added `enhance` to `ServiceProvider`

## 2.0.0-dev.1

### Breaking Changes

- `GenerateServiceProvider.includePackageDependencies` was removed

### Features

- Added a new annotation `GenerateServiceProviderPlugin` to generate a standalone plugin
- Added the `pluginClassName` property to the `GenerateServiceProvider` annotation

## 1.0.0

- First public version

## 0.0.2

- Fix export of EnhanceableProvider
 
## 0.0.1

- Initial version
