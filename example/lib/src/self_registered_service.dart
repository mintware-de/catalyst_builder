import './transport.dart';

abstract class SelfRegisteredService {
  String get foo;

  void sayHello();
}

class MySelfRegisteredService implements SelfRegisteredService {
  final Transport _transport;
  @override
  final String foo;

  MySelfRegisteredService(this._transport, [this.foo = 'bar']);

  @override
  void sayHello() {
    _transport.transferData('Hello from MySelfRegisteredService');
  }
}
