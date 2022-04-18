import 'package:catalyst_builder/src/annotation/annotation.dart';
import 'package:test/test.dart';

void main() {
  test('Parameter constructor', () {
    const parameter = Parameter('test');
    expect(parameter, const TypeMatcher<Parameter>());
    expect(parameter.name, 'test');

    const parameter2 = Parameter('test2');
    expect(parameter2.name, 'test2');
  });
}
