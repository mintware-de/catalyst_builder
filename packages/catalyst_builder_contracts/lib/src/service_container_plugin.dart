import '../catalyst_builder_contracts.dart';

/// Defines a plugin for the [ServiceContainerPlugin]
abstract interface class ServiceContainerPlugin {
  /// Returns all known services that should be registered.
  Map<Type, ServiceDescriptor> provideKnownServices(AbstractServiceContainer p);

  /// Returns a map for the exposing of services.
  Map<Type, Type> provideExposes();

  /// Returns a map that describes what service belongs to which tag
  Map<Symbol, List<Type>> provideServiceTags();

  /// Returns a list of services that should be preloaded.
  List<Type> providePreloadedTypes();
}
