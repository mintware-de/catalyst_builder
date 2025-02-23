import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('exists', () {
    var annotation = const GenerateServiceProvider();
    expect(annotation, const TypeMatcher<GenerateServiceProvider>());
  });
}
