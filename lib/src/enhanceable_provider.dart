import '../catalyst_builder.dart';

/// Describes a class for creating a [ServiceProvider] with additional
/// services and parameters.
abstract class EnhanceableProvider {
  /// Creates a new service provider with additional services and parameters.
  ServiceProvider enhance({
    List<LazyServiceDescriptor> services = const [],
    Map<String, dynamic> parameters = const {},
  });
}
