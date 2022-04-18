import 'dto.dart';

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

  /// True if the service should be preloaded
  final bool preload;

  /// Create a new instance.
  const ExtractedService({
    required this.lifetime,
    required this.service,
    required this.exposeAs,
    required this.constructorArgs,
    required this.preload,
  });

  /// Creates a new instance from the result of [toJson].
  factory ExtractedService.fromJson(Map<String, dynamic> json) {
    return ExtractedService(
      lifetime: json['lifetime'],
      service: SymbolReference.fromJson(json['service']),
      exposeAs: json['exposeAs'] != null
          ? SymbolReference.fromJson(json['exposeAs'])
          : null,
      constructorArgs: (json['constructorArgs'] as List)
          .cast<Map<String, dynamic>>()
          .map(ConstructorArg.fromJson)
          .toList(),
      preload: json['preload'],
    );
  }

  /// Dumps the object in a map that can be used in [ExtractedService.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'lifetime': lifetime,
      'service': service.toJson(),
      'constructorArgs': constructorArgs.map((e) => e.toJson()).toList(),
      'exposeAs': exposeAs?.toJson(),
      'preload': preload,
    };
  }
}
