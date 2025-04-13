import 'package:build/build.dart';

import 'preflight_builder.dart';
import 'service_provider_plugin_builder.dart';

/// Creates the builder for the preflight step
Builder createPreflightBuilder(BuilderOptions options) => PreflightBuilder();

/// Creates the service provider plugin builder
Builder createServiceProviderPluginBuilder(BuilderOptions options) =>
    ServiceProviderPluginBuilder();
