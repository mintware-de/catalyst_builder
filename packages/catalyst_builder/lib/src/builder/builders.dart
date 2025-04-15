import 'package:build/build.dart';

import 'preflight_builder.dart';
import 'service_container_plugin_builder.dart';

/// Creates the builder for the preflight step
Builder createPreflightBuilder(BuilderOptions options) => PreflightBuilder();

/// Creates the service container plugin builder
Builder createServiceContainerPluginBuilder(BuilderOptions options) =>
    ServiceContainerPluginBuilder();
