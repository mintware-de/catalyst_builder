abstract class ServiceProvider {
  T resolve<T>();

  T? tryResolve<T>();
}
