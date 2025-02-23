import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('Preload constructor', () {
    const preload = Preload();
    expect(preload, const TypeMatcher<Preload>());
  });
}
