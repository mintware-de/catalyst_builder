import '../catalyst_builder.dart';

/// A description of a lazy loaded service
class LazyServiceDescriptor<T> {
  /// The service description.
  final Service service;

  /// The factory to produce the service.
  final ServiceFactory factory;

  /// Creates a new [LazyServiceDescriptor] which produces a [T]
  /// using the [factory].
  LazyServiceDescriptor(
    this.factory, [
    this.service = const Service(),
  ]);
}
