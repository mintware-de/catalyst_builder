import 'package:build/build.dart';

import 'preflight_builder.dart';
import 'service_container_plugin_builder.dart';
import 'validation/service_graph_validator.dart';

/// Creates the builder for the preflight step
Builder createPreflightBuilder(BuilderOptions options) => PreflightBuilder();

/// Creates the service container plugin builder.
///
/// Supports the `validation` option (`strict`, `warn` or `off`, default:
/// `warn`) that controls the build time validation of the service graph.
Builder createServiceContainerPluginBuilder(BuilderOptions options) =>
    ServiceContainerPluginBuilder(
      validation: validationModeFromOptions(options.config['validation']),
    );
