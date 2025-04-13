import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:catalyst_builder_example/example.dart';

void main(List<String> arguments) {
  var provider = DefaultServiceProvider();
  provider.useExampleProviderPlugin();

  provider.parameters['sender_username'] = 'Julian';

  print('Post parameter set, pre boot');
  provider.boot();
  print('Post boot, pre resolve');

  var chat = provider.resolve<ChatProvider>();
  print(chat.runtimeType);
  chat.sendChatMessage('WTF, this is really cool!');

  provider.register(
    (provider) => MySelfRegisteredService(provider.resolve()),
  );

  var selfRegistered = provider.resolve<MySelfRegisteredService>();
  selfRegistered.sayHello();

  // Contains CoolChatProvider and ConsoleTransport
  var servicesByTag = provider.resolveByTag(#chat);
  for (var svc in servicesByTag) {
    print(svc);
  }

  var broadcaster = provider.resolve<Broadcaster>();
  broadcaster.sendChatMessage('Hello Broadcast using injection tag.');
}
