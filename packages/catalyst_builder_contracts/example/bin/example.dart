import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:catalyst_builder_contracts_example/my_service.dart';

import 'example.catalyst_builder.plugin.g.dart';

@GenerateServiceContainerPlugin(
  // Enter a name that is used for the service container class
  pluginClassName: 'ExampleContainerPlugin',
)
void main() {
  final container = ServiceContainer();
  container.useExampleContainerPlugin();
  container.boot();

  final service = container.resolve<MyService>();
  service.sayHello();
}
