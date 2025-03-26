import '../catalyst_builder_contracts.dart';

/// Defines a plugin for the [ServiceProvider]
abstract interface class ServiceProviderPlugin {
  /// Returns all known services that should be registered.
  Map<Type, ServiceDescriptor> provideKnownServices(ServiceProvider p);

  /// Returns a map for the exposing of services.
  Map<Type, Type> provideExposes();

  /// Returns a map that describes what service belongs to which tag
  Map<Symbol, List<Type>> provideServiceTags();

  /// Returns a list of services that should be preloaded.
  List<Type> providePreloadedTypes();
}
