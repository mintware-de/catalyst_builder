# Upgrade from v2 to v3

## Changes in `build.yaml`

The options `preflightExtension` and `outputName` has been removed.

```diff
# build.yaml
targets:
  $default:
    auto_apply_builders: true
    builders:
      catalyst_builder|preflight:
        options:
-           preflightExtension: '.catalyst_builder.preflight.json'
      catalyst_builder|buildServiceProvider:
        options:
            providerClassName: 'ExampleProvider'
-           outputName: 'src/example.container.dart'
            includePackageDependencies: true
```

To generate the service provider you've to use the new `@GenerateServiceProvider` annotation.
This annotation will create a `*.example.catalyst_builder.g.dart` when running the build runner.

```diff
 import 'package:catalyst_builder/catalyst_builder.dart';
-import './src/example.container.dart';
+import 'example.catalyst_builder.g.dart';

+@GenerateServiceProvider()
 void main() {}
```