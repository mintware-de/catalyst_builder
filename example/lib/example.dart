import 'package:di_experimental/di_experimental.dart';
import 'package:di_experimental_example/chat_provider.dart';
import './example.container.dart';

@ContainerRoot()
void main(List<String> arguments) {
  var provider = DefaultServiceProvider();
  provider.bindings['username'] = 'Julian';
  var chat = provider.resolve<ChatProvider>();
  print(chat.runtimeType);
  chat.sendChatMessage('WTF, this is really cool!');
}
