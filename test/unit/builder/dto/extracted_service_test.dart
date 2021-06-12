import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late ExtractedService extractedService;
  setUp(() {
    extractedService = ExtractedService(
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
    );
  });

  test('ExtractedService Constructor', () {
    expect(extractedService, TypeMatcher<ExtractedService>());
    expect(extractedService.exposeAs?.library, 'bar');
    expect(extractedService.exposeAs?.symbolName, 'foo');
    expect(extractedService.lifetime, 'ServiceLifetime.singleton');
    expect(extractedService.preload, isTrue);
    expect(extractedService.constructorArgs, isNotEmpty);
    expect(extractedService.constructorArgs[0], TypeMatcher<ConstructorArg>());
    expect(extractedService.service.library, 'baz');
    expect(extractedService.service.symbolName, 'foobar');
  });

  test('toJson fromJson', () {
    var map = extractedService.toJson();
    expect(
      map,
      equals({
        'lifetime': 'ServiceLifetime.singleton',
        'service': anything,
        'constructorArgs': [anything],
        'exposeAs': anything,
        'preload': true,
      }),
    );

    expect(ExtractedService.fromJson(map).toJson(), map);
  });
}
