import 'package:catalyst_builder/catalyst_builder.dart';

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
}
