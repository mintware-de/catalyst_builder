import 'extracted_service.dart';

/// Represents the result of a single file that was processed by the preflight
/// builder.
class PreflightPart {
  /// The extracted services in the file.
  final List<ExtractedService> services;

  /// Creates the preflight part.
  PreflightPart({
    required this.services,
  });

  /// Creates a new instance from the result of [toJson].
  factory PreflightPart.fromJson(Map<String, dynamic> json) {
    return PreflightPart(
      services: (json['services'] as List)
          .map((m) => ExtractedService.fromJson(m))
          .toList(),
    );
  }

  /// Dumps the object in a map that can be used in [PreflightPart.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'services': services.map((e) => e.toJson()).toList(),
    };
  }
}
