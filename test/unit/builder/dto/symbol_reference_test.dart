import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late SymbolReference symbolReference;
  setUp(() {
    symbolReference = SymbolReference(
      library: 'foo',
      symbolName: 'bar',
    );
  });

  test('SymbolReference Constructor', () {
    expect(symbolReference, TypeMatcher<SymbolReference>());
    expect(symbolReference.library, 'foo');
    expect(symbolReference.symbolName, 'bar');
  });

  test('toJson fromJson', () {
    var map = symbolReference.toJson();
    expect(
      map,
      equals({
        'library': 'foo',
        'symbolName': 'bar',
      }),
    );

    expect(SymbolReference.fromJson(map).toJson(), map);
  });
}
