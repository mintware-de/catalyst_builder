part of '../public_api.dart';

abstract class Transport {
  void transferData(String data);
}

@Service(
  exposeAs: Transport,
  tags: [#chat, #transport],
)
class ConsoleTransport implements Transport {
  @override
  void transferData(String data) {
    print('**Sending through console**');
    print(data);
  }
}

@Service(
  tags: [#chat, #transport],
)
class HttpTransport implements Transport {
  @override
  void transferData(String data) {
    print('**Sending over http**');
    print(base64Encode(data.codeUnits));
  }
}
