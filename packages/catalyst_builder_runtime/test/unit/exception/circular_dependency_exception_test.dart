import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = CircularDependencyException([String, int, String]);
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.path, equals([String, int, String]));
    expect(
      ex.message,
      equals('Circular dependency detected: String -> int -> String'),
    );
  });
}
