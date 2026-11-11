import 'abstract_service_container.dart';
import 'annotation/annotation.dart';
import 'service_registry.dart';

/// This class is used for describing services in the service container.
class ServiceDescriptor<T> {
  /// The [Service] that this descriptor describes.
  final Service service;

  /// The factory to create a new instance of the [service].
  ///
  /// The factory receives the container that is currently resolving the
  /// service.
  final ServiceFactory<T> factory;

  /// Creates a new ServiceDescriptor
  const ServiceDescriptor(this.service, this.factory);

  /// Invokes the [factory] to create a new instance of the service.
  ///
  /// The [container] is passed to the factory and is used to resolve
  /// dependencies.
  T produce(AbstractServiceContainer container) => factory(container);
}
