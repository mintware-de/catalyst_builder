import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:catalyst_builder_example/example.dart';

void main(List<String> arguments) {
  var container = ServiceContainer();
  container.useExampleContainerPlugin();

  container.parameters['sender_username'] = 'Julian';

  print('Post parameter set, pre boot');
  container.boot();
  print('Post boot, pre resolve');

  var chat = container.resolve<ChatProvider>();
  print(chat.runtimeType);
  chat.sendChatMessage('WTF, this is really cool!');

  container.register(
    (container) => MySelfRegisteredService(container.resolve()),
  );

  var selfRegistered = container.resolve<MySelfRegisteredService>();
  selfRegistered.sayHello();

  // Contains CoolChatProvider and ConsoleTransport
  var servicesByTag = container.resolveByTag(#chat);
  for (var svc in servicesByTag) {
    print(svc);
  }

  var broadcaster = container.resolve<Broadcaster>();
  broadcaster.sendChatMessage('Hello Broadcast using injection tag.');

  const Type p = ChatProvider;
  // works
  container.resolve<ChatProvider>(p);

  // fails because ChatProvider is not a Broadcaster
  try {
    container.resolve<Broadcaster>(p);
  } catch (_) {
    // ignored
  }

  // Required parameters of a nullable type must be resolved when the
  // service is registered and must not throw when it is not.
  var nullableService = container.resolve<NullableDependencyService>();
  assert(nullableService.transport != null);
  assert(nullableService.unregistered == null);

  // Facing problem 2026-05-01:
  // LazyServiceDescriptor services are not registering tags on enhance

  var enhanced = container.enhance(services: [
    LazyServiceDescriptor((p) => 'Test', const Service(tags: [#theName]))
  ]);
  var taggedServices = enhanced.resolveByTag(#theName);
  assert(1 == taggedServices.length);
  assert('Test' == taggedServices.first);
}
