abstract class ChatProvider {
  abstract final String username;

  Future<void> sendChatMessage(String message);
}
