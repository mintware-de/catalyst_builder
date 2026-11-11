part of '../public_api.dart';

/// A scoped service that is disposed together with the scope that created
/// it.
///
/// The static counters allow the example to verify that every scope gets
/// its own instance and that disposal happens per scope.
@Service(lifetime: ServiceLifetime.scoped)
class RequestContext implements Disposable {
  /// The number of instances that were created.
  static int created = 0;

  /// The number of instances that were disposed.
  static int disposed = 0;

  bool _isDisposed = false;

  /// True after [dispose] was called on this instance.
  bool get isDisposed => _isDisposed;

  /// Creates a new [RequestContext].
  RequestContext() {
    created++;
  }

  @override
  void dispose() {
    _isDisposed = true;
    disposed++;
  }
}
