import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

@Service()
class ThirdPartyService {}

@Service()
class ServiceThatDependOnEnhancedService {
  final ServiceOnlyProvidedInEnhanced dependency;

  ServiceThatDependOnEnhancedService(this.dependency);
}

class ServiceOnlyProvidedInEnhanced {
  final String foo = 'bar';
}

@Service()
class SingletonThatShouldBeRegisteredInRoot {
  static var _count = 0;

  int get count => _count;

  SingletonThatShouldBeRegisteredInRoot() {
    _count++;
  }
}
