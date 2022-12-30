library catalyst_builder_example;

import 'dart:convert';

import 'package:catalyst_builder/catalyst_builder.dart';

import './src/manually_wired_service.dart';

export './src/manually_wired_service.dart';
export 'example.catalyst_builder.g.dart';

part './src/chat_provider.dart';

part './src/cool_chat_provider.dart';

part './src/preload_service.dart';

part './src/singleton_service.dart';

part './src/transient_service.dart';

part './src/transport.dart';

part './src/self_registered_service.dart';

part './src/broadcaster.dart';

@Preload()
@GenerateServiceProvider()
@ServiceMap(services: {
  ManuallyWiredServiceImplementation: Service(
    exposeAs: ManuallyWiredService,
  ),
})
void main() {}
