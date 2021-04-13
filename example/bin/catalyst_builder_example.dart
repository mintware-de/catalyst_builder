import 'package:catalyst_builder_example/example.dart';

void main(List<String> arguments) {
  var provider = ExampleProvider();
  provider.parameters['sender_username'] = 'Julian';
  var chat = provider.resolve<ChatProvider>();
  print(chat.runtimeType);
  chat.sendChatMessage('WTF, this is really cool!');
}

//
