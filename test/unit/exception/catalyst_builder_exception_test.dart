import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

class _Tmp extends CatalystBuilderException {
  _Tmp(super.message, [super.inner]);
}

void main() {
  test('constructor', () {
    var inner = _Tmp('bar');
    var ex = _Tmp('foo', inner);
    expect(ex, const TypeMatcher<CatalystBuilderException>());
    expect(ex.message, equals('foo'));
    expect(ex.inner, equals(inner));
  });

  test('toString', () {
    var inner = _Tmp('bar');
    var inner2 = _Tmp('baz', inner);
    var ex = _Tmp('foo', inner2);
    expect(inner.toString(), equals('CatalystBuilderException: bar'));
    expect(
      ex.toString(),
      equals('''
CatalystBuilderException: foo
\tInner Exception: baz
\t\tInner Exception: bar
'''
          .trim()),
    );
  });
}
