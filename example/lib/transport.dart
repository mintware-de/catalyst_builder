import 'package:di_experimental/di_experimental.dart';

abstract class Transport {
  void transferData(String data);
}

@Service(exposeAs: Transport)
class ConsoleTransport implements Transport {
  @override
  void transferData(String data) {
    print('**Sending through console**');
    print(data);
  }
}
