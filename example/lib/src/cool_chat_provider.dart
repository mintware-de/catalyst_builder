part of '../public_api.dart';

@Service(
  exposeAs: ChatProvider,
  tags: [#chat, #chat_provider],
)
class CoolChatProvider implements ChatProvider {
  Transport transport;

  @override
  final String username;

  CoolChatProvider({
    required this.transport,
    @Inject(parameter: 'sender_username') required this.username,
  });

  @override
  Future<void> sendChatMessage(String message) async {
    transport.transferData('CoolChatProvider: $username wrote $message');
  }
}
