import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('ServiceDescriptor constructor', () {
    var descriptor = ServiceDescriptor<int>(
      const Service(exposeAs: int),
      (c) => 1337,
    );
    expect(descriptor.service.exposeAs, equals(int));
    expect(descriptor.factory, isNotNull);
    expect(descriptor.produce(ServiceContainer()), equals(1337));
  });
}
