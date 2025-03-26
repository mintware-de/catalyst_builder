/// Represents a simple symbol reference.
class Entrypoint {
  /// The name of the service provider class.
  final String providerClassName;

  /// The assetId
  final Uri assetId;

  /// The name of the plugin class.
  final String pluginClassName;

  /// Instantiate a new entrypoint
  const Entrypoint({
    required this.providerClassName,
    required this.assetId,
    required this.pluginClassName,
  });

  /// Creates a new instance from the result of [toJson].
  factory Entrypoint.fromJson(Map<String, dynamic> json) {
    return Entrypoint(
      providerClassName: json['entrypoint'].toString(),
      assetId: Uri.parse(json['assetId'].toString()),
      pluginClassName: json['pluginClassName'].toString(),
    );
  }

  /// Dumps the object in a map that can be used in [Entrypoint.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'entrypoint': providerClassName,
      'assetId': assetId.toString(),
      'pluginClassName': pluginClassName,
    };
  }
}
