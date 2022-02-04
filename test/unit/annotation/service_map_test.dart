import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

void main() {
  test('ServiceMap Constructor', () {
    const serviceMap = ServiceMap(services: {
      String: Service(lifetime: ServiceLifetime.transient, exposeAs: int),
    });
    expect(serviceMap.services, hasLength(1));
    expect(
      serviceMap.services[String]!.lifetime,
      equals(ServiceLifetime.transient),
    );
    expect(
      serviceMap.services[String]!.exposeAs,
      equals(int),
    );
  });
}
