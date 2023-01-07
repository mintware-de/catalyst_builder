/// Represents the extracted Inject annotation
class InjectAnnotation {
  /// The extracted value for Inject.tag
  final String? tag;

  /// The extracted value for Inject.parameter.
  final String? parameter;

  const InjectAnnotation({
    this.tag,
    this.parameter,
  });

  /// Creates a new instance from the result of [toJson].
  factory InjectAnnotation.fromJson(Map<String, dynamic> json) {
    return InjectAnnotation(
      tag: json['tag']?.toString(),
      parameter: json['parameter']?.toString(),
    );
  }

  /// Dumps the object in a map that can be used in [InjectAnnotation.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'parameter': parameter,
    };
  }
}
