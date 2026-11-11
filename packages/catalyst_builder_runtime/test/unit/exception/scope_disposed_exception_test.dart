import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  test('constructor', () {
    var ex = const ScopeDisposedException();
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('This scope has already been disposed.'));
  });
}
