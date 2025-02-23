import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = ServiceNotFoundException(String);
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('Service String not found.'));
  });
}
