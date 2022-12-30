import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:test/test.dart';

void main() {
  late InjectAnnotation annotation;

  setUp(() {
    annotation = InjectAnnotation(tag: 'foo', parameter: 'bar');
  });

  test('InjectAnnotation constructor', () {
    expect(annotation.tag, equals('foo'));
    expect(annotation.parameter, equals('bar'));
  });

  test('toJson fromJson', () {
    var map = annotation.toJson();
    expect(
      map,
      equals({
        'tag': 'foo',
        'parameter': 'bar',
      }),
    );

    expect(InjectAnnotation.fromJson(map).toJson(), map);
  });
}
