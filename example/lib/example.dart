library catalyst_builder_example;

import 'package:catalyst_builder/catalyst_builder.dart';

import './src/manually_wired_service.dart';

export './src/chat_provider.dart';
export './src/cool_chat_provider.dart';
export './src/example.container.dart';
export './src/manually_wired_service.dart';
export './src/preload_service.dart';
export './src/singleton_service.dart';
export './src/transient_service.dart';
export './src/transport.dart';

@Preload()
@ServiceMap(services: {
  ManuallyWiredServiceImplementation: Service(
    exposeAs: ManuallyWiredService,
  ),
})
void main() {}
