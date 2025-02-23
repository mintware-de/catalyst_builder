import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:catalyst_builder_contracts_example/my_service.dart';

import 'example.catalyst_builder.g.dart';

@GenerateServiceProvider(
  // Enter a name that is used for the service provider class
  providerClassName: 'ExampleProvider',
)
void main() {
  final provider = ExampleProvider();
  provider.boot();

  final service = provider.resolve<MyService>();
  service.sayHello();
}
