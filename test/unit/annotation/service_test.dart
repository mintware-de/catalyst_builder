import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('Service Constructor', () {
    const simpleService = Service();
    expect(simpleService, const TypeMatcher<Service>());

    expect(simpleService.exposeAs, isNull);
    expect(simpleService.lifetime, ServiceLifetime.singleton);

    const serviceWithLifetime = Service(lifetime: ServiceLifetime.transient);
    expect(serviceWithLifetime.exposeAs, isNull);
    expect(serviceWithLifetime.lifetime, ServiceLifetime.transient);
    expect(serviceWithLifetime.tags, isEmpty);

    const serviceWithAdditionalProperties = Service(
      lifetime: ServiceLifetime.transient,
      exposeAs: String,
      tags: [#tag1, #tag2]
    );
    expect(serviceWithAdditionalProperties.exposeAs, const TypeMatcher<Type>());
    expect(serviceWithAdditionalProperties.exposeAs, equals(String));
    expect(serviceWithAdditionalProperties.lifetime, ServiceLifetime.transient);
    expect(serviceWithAdditionalProperties.tags, equals([#tag1, #tag2]));
  });
}
