import '../catalyst_builder.dart';

class LazyServiceDescriptor<T> {
  final Service service;
  final T Function(ServiceProvider) factory;

  LazyServiceDescriptor(this.factory, [this.service = const Service()]);
}
