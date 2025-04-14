import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ContainerAlreadyBootedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('The service provider was already booted.'));
  });
}
