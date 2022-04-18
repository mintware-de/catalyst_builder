import './transport.dart';

abstract class SelfRegisteredService {
  void sayHello();
}

class MySelfRegisteredService implements SelfRegisteredService {
  final Transport _transport;

  MySelfRegisteredService(this._transport);

  @override
  void sayHello() {
    _transport.transferData('Hello from MySelfRegisteredService');
  }
}
