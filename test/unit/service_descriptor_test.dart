import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main(){
  test('ServiceDescriptor constructor', () {
    var descriptor = ServiceDescriptor<int>(Service(exposeAs: int), () => 1337);
    expect(descriptor.service.exposeAs, equals(int));
    expect(descriptor.produce(), equals(1337));
  });
}