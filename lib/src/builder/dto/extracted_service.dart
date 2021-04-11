import 'dto.dart';
import 'symbol_reference.dart';

/// Represents a class that was decorated with [Service].
class ExtractedService {
  /// The lifetime of the service
  final String lifetime;

  /// The reference to the class
  final SymbolReference service;

  /// Describes how the service is exposed.
  final SymbolReference? exposeAs;

  /// The arguments of the default constructor.
  final List<ConstructorArg> constructorArgs;

  /// Create a new instance.
  const ExtractedService({
    required this.lifetime,
    required this.service,
    required this.exposeAs,
    required this.constructorArgs,
  });

  /// Creates a new instance from the result of [toJson].
  factory ExtractedService.fromJson(Map<String, dynamic> json) {
    return ExtractedService(
      lifetime: json['lifetime'],
      service: SymbolReference.fromJson(json['service']),
      constructorArgs: (json['constructorArgs'] as List)
          .map((m) => ConstructorArg.fromJson(m))
          .toList(),
      exposeAs: json['exposeAs'] != null
          ? SymbolReference.fromJson(json['exposeAs'])
          : null,
    );
  }

  /// Dumps the object in a map that can be used in [ExtractedService.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'lifetime': lifetime,
      'service': service.toJson(),
      'constructorArgs': constructorArgs.map((e) => e.toJson()).toList(),
      'exposeAs': exposeAs?.toJson(),
    };
  }
}
