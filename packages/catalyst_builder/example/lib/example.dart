import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

import './src/manually_wired_service.dart';

export './public_api.dart';
export './src/manually_wired_service.dart';
export 'example.catalyst_builder.g.dart';

@Preload()
@GenerateServiceProvider(
  providerClassName: 'ExampleProvider',
)
@ServiceMap(services: {
  ManuallyWiredServiceImplementation: Service(
    exposeAs: ManuallyWiredService,
  ),
})
void main() {}
