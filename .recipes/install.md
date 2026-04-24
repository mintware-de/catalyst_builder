# Catalyst Builder install recipe

This recipe is used for installing and set up the catalyst_builder dart package.

## Variables

- `~pluginName~`: PascalCase name for the plugin class
- `~entrypointFile~`: File that declares the main method

## Workflow

1. Install the dependencies: `dart pub add dev:build_runner catalyst_builder catalyst_builder_contracts`
2. Ask the User for `~pluginName~`
3. Find the file (`~entrypointFile~.dart`) that declares the entry point (`main()`)
4. Add this imports to that file:
    - `import 'package:catalyst_builder/catalyst_builder.dart';`
    - `import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';`
    - `import '~entrypointFile~.catalyst_builder.plugin.g.dart';`
5. Add to the main method the annotation `@GenerateServiceContainerPlugin(pluginClassName: '~pluginName~')`
6. Add this code directly at the beginning of the method:
```
// Create a new instance of the service container
final container = ServiceContainer();
// Register the services from our app
container.use~pluginName~();
// Boot the container
container.boot();
```
7. Run `dart run build_runner build` to build the service container
8. Run `dart analyze` to check if everything is ok
9. Ask the user if he wants to .gitignore the generated service container file (
   `~entrypointFile~.catalyst_builder.plugin.g.dart`)
10. Ask the user if the changes above should be commited with this message (or suggest a based on the commiting
    guidelines):
```plain
change: Added catalyst_builder for dependency injection

documentation can be found here: https://github.com/mintware-de/catalyst_builder/wiki
```
