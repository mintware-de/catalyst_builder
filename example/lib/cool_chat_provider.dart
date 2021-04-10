import 'package:di_experimental/di_experimental.dart';
import 'package:di_experimental_example/transport.dart';

import 'chat_provider.dart';

@Service(
  exposeAs: ChatProvider,
)
class CoolChatProvider implements ChatProvider {
  Transport transport;
  String username;

  CoolChatProvider({
    required this.transport,
    required this.username,
  });

  @override
  Future<void> sendChatMessage(String message) async {
    transport.transferData('CoolChatProvider: $username wrote $message');
  }
}
