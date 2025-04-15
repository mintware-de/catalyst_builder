import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

import './src/manually_wired_service.dart';

export './public_api.dart';
export './src/manually_wired_service.dart';
export 'example.catalyst_builder.plugin.g.dart';

@Preload()
@GenerateServiceContainerPlugin(
  pluginClassName: 'ExampleContainerPlugin',
)
@ServiceMap(services: {
  ManuallyWiredServiceImplementation: Service(
    exposeAs: ManuallyWiredService,
  ),
})
void main() {}
