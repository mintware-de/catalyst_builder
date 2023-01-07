import 'package:catalyst_builder/catalyst_builder.dart';

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
