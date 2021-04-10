import './service_provider.dart';
import 'service.dart';

class ServiceDescriptor<T> {
  final Service _service;
  final T Function(ServiceProvider) _factory;

  Service get service => _service;

  T produce(ServiceProvider provider) => _factory(provider);

  ServiceDescriptor(this._service, this._factory);
}
