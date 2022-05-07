import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = ServiceNotFoundException(String);
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('Service String not found.'));
  });
}
