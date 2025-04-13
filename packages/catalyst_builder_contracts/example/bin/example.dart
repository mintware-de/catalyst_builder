import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:catalyst_builder_contracts_example/my_service.dart';

import 'example.catalyst_builder.plugin.g.dart';

@GenerateServiceProviderPlugin(
  // Enter a name that is used for the service provider class
  pluginClassName: 'ExampleProviderPlugin',
)
void main() {
  final provider = DefaultServiceProvider();
  provider.useExampleProviderPlugin();
  provider.boot();

  final service = provider.resolve<MyService>();
  service.sayHello();
}
