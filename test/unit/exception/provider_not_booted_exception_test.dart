import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ProviderNotBootedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(
      ex.message,
      equals(
        'Service provider was not booted. Call ServiceProvider.boot() first.',
      ),
    );
  });
}
