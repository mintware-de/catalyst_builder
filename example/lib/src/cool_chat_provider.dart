import 'package:catalyst_builder/catalyst_builder.dart';

import './transport.dart';
import 'chat_provider.dart';

@Service(
  exposeAs: ChatProvider,
)
class CoolChatProvider implements ChatProvider {
  Transport transport;

  @override
  final String username;

  CoolChatProvider({
    required this.transport,
    @Parameter('sender_username') required this.username,
  });

  @override
  Future<void> sendChatMessage(String message) async {
    transport.transferData('CoolChatProvider: $username wrote $message');
  }
}
