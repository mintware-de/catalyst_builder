import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('ServiceDescriptor constructor', () {
    var descriptor = ServiceDescriptor<int>(
      const Service(exposeAs: int),
      () => 1337,
    );
    expect(descriptor.service.exposeAs, equals(int));
    expect(descriptor.produce(), equals(1337));
  });
}
