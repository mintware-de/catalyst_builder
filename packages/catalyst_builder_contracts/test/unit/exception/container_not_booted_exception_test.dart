import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ContainerNotBootedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(
      ex.message,
      equals(
        'Service provider was not booted. Call ServiceProvider.boot() first.',
      ),
    );
  });
}
