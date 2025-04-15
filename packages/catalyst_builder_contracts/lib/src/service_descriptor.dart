import 'annotation/annotation.dart';

/// This class is used for describing services in the service container.
class ServiceDescriptor<T> {
  final Service _service;

  /// The factory to create a new instance of the [_service].
  final T Function() _factory;

  /// The [Service] that this descriptor describes.
  Service get service => _service;

  /// Invokes the [_factory] to create a new instance of the service.
  T produce() => _factory();

  /// Creates a new ServiceDescriptor
  ServiceDescriptor(this._service, this._factory);
}
