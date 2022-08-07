import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('exists', () {
    var annotation = const GenerateServiceProvider();
    expect(annotation, const TypeMatcher<GenerateServiceProvider>());
  });
}
