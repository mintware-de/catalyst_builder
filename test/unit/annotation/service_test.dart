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

    const serviceWithLifetimeAndExposeAs = Service(
      lifetime: ServiceLifetime.transient,
      exposeAs: String,
    );
    expect(serviceWithLifetimeAndExposeAs.exposeAs, const TypeMatcher<Type>());
    expect(serviceWithLifetimeAndExposeAs.exposeAs, equals(String));
    expect(serviceWithLifetimeAndExposeAs.lifetime, ServiceLifetime.transient);
  });
}
