/// Represents a simple symbol reference.
class Entrypoint {
  /// The name of the service provider class.
  final String providerClassName;

  /// The assetId
  final Uri assetId;

  /// Instantiate a new entrypoint
  const Entrypoint({
    required this.providerClassName,
    required this.assetId,
  });

  /// Creates a new instance from the result of [toJson].
  factory Entrypoint.fromJson(Map<String, dynamic> json) {
    return Entrypoint(
      providerClassName: json['entrypoint'].toString(),
      assetId: Uri.parse(json['assetId'].toString()),
    );
  }

  /// Dumps the object in a map that can be used in [Entrypoint.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'entrypoint': providerClassName,
      'assetId': assetId.toString(),
    };
  }
}
