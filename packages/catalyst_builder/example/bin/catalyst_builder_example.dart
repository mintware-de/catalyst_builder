import 'package:catalyst_builder/catalyst_builder.dart';
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
}
