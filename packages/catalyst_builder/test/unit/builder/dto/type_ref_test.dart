import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late TypeRef typeRef;
  setUp(() {
    typeRef = const TypeRef(
      symbolName: 'List',
      typeArguments: [
        TypeRef(
          symbolName: 'Logger',
          library: 'package:app/logger.dart',
        ),
      ],
      isNullable: true,
    );
  });

  test('TypeRef Constructor', () {
    expect(typeRef, const TypeMatcher<TypeRef>());
    expect(typeRef.symbolName, 'List');
    expect(typeRef.library, isNull);
    expect(typeRef.typeArguments, hasLength(1));
    expect(typeRef.typeArguments.single.symbolName, 'Logger');
    expect(
      typeRef.typeArguments.single.library,
      'package:app/logger.dart',
    );
    expect(typeRef.isNullable, isTrue);
  });

  test('toJson fromJson', () {
    var map = typeRef.toJson();
    expect(
      map,
      equals({
        'symbolName': 'List',
        'library': null,
        'typeArguments': [
          {
            'symbolName': 'Logger',
            'library': 'package:app/logger.dart',
            'typeArguments': <Map<String, dynamic>>[],
            'isNullable': false,
          },
        ],
        'isNullable': true,
      }),
    );

    expect(TypeRef.fromJson(map).toJson(), map);
  });
}
