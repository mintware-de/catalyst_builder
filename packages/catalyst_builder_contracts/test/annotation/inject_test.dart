import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('Inject constructor', () {
    const inject = Inject(tag: #foo, parameter: 'bar');
    expect(inject, const TypeMatcher<Inject>());

    expect(inject.tag, equals(Symbol('foo')));
    expect(inject.parameter, equals('bar'));
  });
}
