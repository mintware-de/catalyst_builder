import 'package:catalyst_builder/catalyst_builder.dart';
import './transport.dart';

import 'chat_provider.dart';

@Service(
  exposeAs: ChatProvider,
)
@Preload()
class CoolChatProvider implements ChatProvider {
  Transport transport;
  String username;

  CoolChatProvider({
    required this.transport,
    @Parameter('sender_username') required this.username,
  }) {
    print('Chat provider created');
  }

  @override
  Future<void> sendChatMessage(String message) async {
    transport.transferData('CoolChatProvider: $username wrote $message');
  }
}
