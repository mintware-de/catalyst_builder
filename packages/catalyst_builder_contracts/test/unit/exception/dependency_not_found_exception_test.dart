import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = DependencyNotFoundException(String, 'string');
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.requiredBy, equals(String));
    expect(ex.parameterName, equals('string'));
    expect(
      ex.message,
      equals(
        'One or more dependencies of String was not found. (Parameter: string)',
      ),
    );
  });
}
