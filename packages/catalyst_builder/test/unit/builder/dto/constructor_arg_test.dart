import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late ConstructorArg constructorArg;
  setUp(() {
    constructorArg = const ConstructorArg(
      name: 'nullArg',
      defaultValue: 'null',
      isOptional: true,
      isPositional: false,
      isNamed: true,
      inject: InjectAnnotation(tag: 'foo'),
      type: TypeRef(
        symbolName: 'Logger',
        library: 'package:app/logger.dart',
        isNullable: true,
      ),
      isNullable: true,
    );
  });

  test('ConstructorArg Constructor', () {
    expect(constructorArg, const TypeMatcher<ConstructorArg>());
    expect(constructorArg.name, 'nullArg');
    expect(constructorArg.defaultValue, 'null');
    expect(constructorArg.isOptional, isTrue);
    expect(constructorArg.isPositional, isFalse);
    expect(constructorArg.isNamed, isTrue);
    expect(constructorArg.inject, isNotNull);
    expect(constructorArg.type?.symbolName, 'Logger');
    expect(constructorArg.isNullable, isTrue);
  });

  test('toJson fromJson', () {
    var map = constructorArg.toJson();
    expect(
      map,
      equals({
        'name': 'nullArg',
        'isOptional': true,
        'isNamed': true,
        'isPositional': false,
        'defaultValue': 'null',
        'inject': containsPair('tag', 'foo'),
        'type': {
          'symbolName': 'Logger',
          'library': 'package:app/logger.dart',
          'typeArguments': <Map<String, dynamic>>[],
          'isNullable': true,
        },
        'isNullable': true,
      }),
    );

    expect(ConstructorArg.fromJson(map).toJson(), map);
  });

  test('fromJson without type information', () {
    // Old preflight files don't contain the type fields.
    var arg = ConstructorArg.fromJson({
      'name': 'arg',
      'defaultValue': '',
      'isOptional': false,
      'isPositional': true,
      'isNamed': false,
      'inject': null,
    });
    expect(arg.type, isNull);
    expect(arg.isNullable, isFalse);
  });
}
