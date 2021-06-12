import 'package:catalyst_builder/catalyst_builder.dart';

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

