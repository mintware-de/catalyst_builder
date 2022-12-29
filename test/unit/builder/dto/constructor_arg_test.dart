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
      boundParameter: 'nullArg',
      inject: InjectAnnotation(tag: 'foo'),
    );
  });

  test('ConstructorArg Constructor', () {
    expect(constructorArg, const TypeMatcher<ConstructorArg>());
    expect(constructorArg.name, 'nullArg');
    expect(constructorArg.defaultValue, 'null');
    expect(constructorArg.isOptional, isTrue);
    expect(constructorArg.isPositional, isFalse);
    expect(constructorArg.isNamed, isTrue);
    expect(constructorArg.boundParameter, 'nullArg');
    expect(constructorArg.inject, isNotNull);
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
        'boundParameter': 'nullArg',
        'inject': {'tag': 'foo'},
      }),
    );

    expect(ConstructorArg.fromJson(map).toJson(), map);
  });
}
