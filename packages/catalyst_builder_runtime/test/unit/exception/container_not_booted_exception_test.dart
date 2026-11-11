import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ContainerNotBootedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(
      ex.message,
      equals(
        'Service container was not booted. Call ServiceContainer.boot() first.',
      ),
    );
  });
}
