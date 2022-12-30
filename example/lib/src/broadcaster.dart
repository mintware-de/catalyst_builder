part of '../example.dart';

@Service()
class Broadcaster implements ChatProvider {
  List<Transport> transports;

  Broadcaster(
    @Inject(tag: #transport) this.transports,
  );

  @override
  Future<void> sendChatMessage(String message) async {
    for (var transport in transports) {
      print('Sending to ${transport.runtimeType}');
      transport.transferData(message);
    }
  }

  @override
  String get username => 'Broadcaster User';
}
