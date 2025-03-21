import 'package:build/build.dart';

import 'entrypoint_builder.dart';
import 'preflight_builder.dart';
import 'service_provider_builder.dart';

/// Creates the entrypoint builder
Builder createEntrypointBuilder(BuilderOptions options) => EntrypointBuilder();

/// Creates the builder for the preflight step
Builder createPreflightBuilder(BuilderOptions options) => PreflightBuilder();

/// Creates the service provider builder
PostProcessBuilder createServiceProviderBuilder(BuilderOptions options) =>
    ServiceProviderBuilder();
