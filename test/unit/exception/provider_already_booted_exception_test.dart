import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ProviderAlreadyBootedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('The service provider was already booted.'));
  });
}
