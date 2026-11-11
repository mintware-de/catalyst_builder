import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = ScopeRequiredException(String);
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.service, equals(String));
    expect(
      ex.message,
      equals(
        'Service String is scoped and must be resolved from a scope '
        '(createScope()).',
      ),
    );
  });
}
