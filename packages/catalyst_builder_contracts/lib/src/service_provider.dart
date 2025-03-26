import '../catalyst_builder_contracts.dart';

/// Describes a simple ServiceProvider
abstract class ServiceProvider {
  /// Additional provider parameters.
  /// If a service is not registered, the provider will also look inside
  /// the [parameters]. If there is a entry that match the name of the service
  /// parameter and the type matches the expected type, this parameter is used.
  final Map<String, dynamic> parameters = <String, dynamic>{};

  /// Resolves a [Service] of the given [T]ype.
  ///
  /// If the service does not exist, an [Exception] is thrown.
  T resolve<T>();

  /// Resolves all registered services with the given [tag].
  List<dynamic> resolveByTag(Symbol tag);

  /// Try to resolve a [Service] of the given [T]ype.
  ///
  /// If the service does not exist, null is returned.
  T? tryResolve<T>();

  /// Checks if a with the [T] or [type] is registered.
  bool has<T>([Type? type]);

  /// Boot the service container.
  /// While booting the service provider, preloaded services are instantiated.
  void boot();

  /// Resolves a service or gets a matching parameter.
  /// If neither a service nor a parameter is found, an exception is thrown.
  T resolveOrGetParameter<T>(
    Type requiredBy,
    String param, [
    String? parameter,
  ]);

  /// Try to resolve a service of the type [T].
  /// If there is no matching service, try to resolve a [parameter] of the type
  /// [T]. If no parameter exists, return null;
  T? tryResolveOrGetParameter<T>(String parameter);

  /// Applies a plugin to the service provider
  void applyPlugin(ServiceProviderPlugin plugin);
}
