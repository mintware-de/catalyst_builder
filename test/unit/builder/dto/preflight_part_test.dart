import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late PreflightPart preflightPart;
  setUp(() {
    preflightPart = PreflightPart(services: [
      const ExtractedService(
        exposeAs: SymbolReference(symbolName: 'foo', library: 'bar'),
        lifetime: 'ServiceLifetime.singleton',
        preload: true,
        constructorArgs: [
          ConstructorArg(
            name: 'nullArg',
            defaultValue: 'null',
            isOptional: true,
            isPositional: false,
            isNamed: true,
            boundParameter: 'nullArg',
          )
        ],
        service: SymbolReference(symbolName: 'foobar', library: 'baz'),
      )
    ]);
  });

  test('PreflightPart Constructor', () {
    expect(preflightPart, const TypeMatcher<PreflightPart>());
    expect(preflightPart.services, isNotEmpty);
    expect(preflightPart.services[0], const TypeMatcher<ExtractedService>());
  });

  test('toJson fromJson', () {
    var map = preflightPart.toJson();
    expect(
      map,
      equals({
        'services': [
          anything,
        ],
      }),
    );

    expect(PreflightPart.fromJson(map).toJson(), map);
  });
}
