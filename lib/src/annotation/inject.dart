/// Inject a specific parameter or a list of services with a specific tag.
/// You can only use one property.
class Inject {
  /// If [tag] is set, the provider will inject an array with all services with the given tag.
  /// If no services are tagged with the tag, an empty list will be injected.
  final Symbol? tag;

  /// Creates a new inject annotation.
  const Inject({this.tag});
}
