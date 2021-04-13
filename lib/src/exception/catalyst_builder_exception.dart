/// A base class for CatalystBuilder specific exceptions
abstract class CatalystBuilderException implements Exception {
  /// The exception [message]
  final String message;

  /// A inner exception
  final CatalystBuilderException? inner;

  /// Creates a exception with the given [message]
  const CatalystBuilderException(this.message, [this.inner]);

  String _fullMessage([int level = 1]) =>
      message +
      (inner != null
          ? '\n${'\t' * level}Inner Exception: '
              '${inner!._fullMessage(level + 1)}'
          : '');

  String toString() {
    return "CatalystBuilderException: ${_fullMessage()}";
  }
}
