import 'package:catalyst_builder_example/example.dart';

void main(List<String> arguments) {
  var provider = ExampleProvider();
  provider.parameters['sender_username'] = 'Julian';

  print('Post parameter set, pre boot');
  provider.boot();
  print('Post boot, pre resolve');

  var chat = provider.resolve<ChatProvider>();
  print(chat.runtimeType);
  chat.sendChatMessage('WTF, this is really cool!');
}

//
