import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    factory(p) => '';
    var service = const Service(lifetime: ServiceLifetime.transient);
    var lazyServiceDescriptor = LazyServiceDescriptor(factory, service);
    expect(lazyServiceDescriptor.factory, equals(factory));
    expect(lazyServiceDescriptor.service, equals(service));
    expect(lazyServiceDescriptor.returnType, equals(String));
  });
}
