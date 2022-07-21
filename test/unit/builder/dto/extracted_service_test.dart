import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late ExtractedService extractedService;
  setUp(() {
    extractedService = const ExtractedService(
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
      tags: ['testing', 'another'],
    );
  });

  test('ExtractedService Constructor', () {
    expect(extractedService, const TypeMatcher<ExtractedService>());
    expect(extractedService.exposeAs?.library, 'bar');
    expect(extractedService.exposeAs?.symbolName, 'foo');
    expect(extractedService.lifetime, 'ServiceLifetime.singleton');
    expect(extractedService.preload, isTrue);
    expect(extractedService.constructorArgs, isNotEmpty);
    expect(
      extractedService.constructorArgs[0],
      const TypeMatcher<ConstructorArg>(),
    );
    expect(extractedService.service.library, 'baz');
    expect(extractedService.service.symbolName, 'foobar');
    expect(extractedService.tags, equals(['testing', 'another']));
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
        'tags': ['testing', 'another']
      }),
    );

    expect(ExtractedService.fromJson(map).toJson(), map);
  });
}
