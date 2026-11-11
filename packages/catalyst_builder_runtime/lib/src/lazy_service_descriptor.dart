import 'annotation/annotation.dart';
import 'service_registry.dart';

/// A description of a lazy loaded service
class LazyServiceDescriptor<T> {
  /// The service description.
  final Service service;

  /// The factory to produce the service.
  final ServiceFactory<T> factory;

  /// The return type of the factory.
  final Type returnType;

  /// Creates a new [LazyServiceDescriptor] which produces a [T]
  /// using the [factory].
  LazyServiceDescriptor(
    this.factory, [
    this.service = const Service(),
  ]) : returnType = T;
}
