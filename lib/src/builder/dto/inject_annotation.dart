/// Represents the extracted Inject annotation
class InjectAnnotation {
  final String? tag;

  const InjectAnnotation({
    this.tag,
  });

  /// Creates a new instance from the result of [toJson].
  factory InjectAnnotation.fromJson(Map<String, dynamic> json) {
    return InjectAnnotation(
      tag: json['tag'],
    );
  }

  /// Dumps the object in a map that can be used in [InjectAnnotation.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
    };
  }
}
