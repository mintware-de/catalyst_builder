import 'package:catalyst_builder/src/annotation/annotation.dart';
import 'package:test/test.dart';

void main() {
  test('Preload constructor', () {
    const preload = Preload();
    expect(preload, TypeMatcher<Preload>());
  });
}
