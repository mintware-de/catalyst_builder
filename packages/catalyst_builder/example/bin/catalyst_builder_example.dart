import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:catalyst_builder_example/example.dart';

Future<void> main(List<String> arguments) async {
  var container = ServiceContainer();
  container.useExampleContainerPlugin();

  container.parameters['sender_username'] = 'Julian';

  print('Post parameter set, pre boot');
  container.boot();
  print('Post boot, pre resolve');

  var chat = container.resolve<ChatProvider>();
  print(chat.runtimeType);
  await chat.sendChatMessage('WTF, this is really cool!');

  container.register(
    (container) => MySelfRegisteredService(container.resolve()),
  );

  var selfRegistered = container.resolve<MySelfRegisteredService>();
  selfRegistered.sayHello();

  // Contains CoolChatProvider and ConsoleTransport
  var servicesByTag = container.resolveByTag(#chat);
  for (var svc in servicesByTag) {
    print(svc);
  }

  var broadcaster = container.resolve<Broadcaster>();
  await broadcaster.sendChatMessage('Hello Broadcast using injection tag.');

  const Type p = ChatProvider;
  // works
  container.resolve<ChatProvider>(p);

  // fails because ChatProvider is not a Broadcaster
  try {
    container.resolve<Broadcaster>(p);
  } catch (_) {
    // ignored
  }

  // Required parameters of a nullable type must be resolved when the
  // service is registered and must not throw when it is not.
  var nullableService = container.resolve<NullableDependencyService>();
  assert(nullableService.transport != null);
  assert(nullableService.unregistered == null);

  // Facing problem 2026-05-01:
  // LazyServiceDescriptor services are not registering tags on createScope

  var scope = container.createScope(services: [
    LazyServiceDescriptor((p) => 'Test', const Service(tags: [#theName]))
  ]);
  var taggedServices = scope.resolveByTag(#theName);
  assert(1 == taggedServices.length);
  assert('Test' == taggedServices.first);

  // Scoped services: every scope gets its own RequestContext instance and
  // disposes it on dispose(). The root container cannot resolve them.
  expectThrows(() => container.resolve<RequestContext>());

  var scope1 = container.createScope();
  var scope2 = container.createScope();

  var context1a = scope1.resolve<RequestContext>();
  var context1b = scope1.resolve<RequestContext>();
  var context2 = scope2.resolve<RequestContext>();

  // Same instance within one scope, different across scopes.
  assert(identical(context1a, context1b));
  assert(!identical(context1a, context2));
  assert(RequestContext.created == 2);
  assert(RequestContext.disposed == 0);

  await scope1.dispose();
  assert(context1a.isDisposed);
  assert(!context2.isDisposed);
  assert(scope1.isDisposed);

  await scope2.dispose();
  assert(RequestContext.created == 2);
  assert(RequestContext.disposed == 2);

  print('Scoped services work.');
}

void expectThrows(void Function() action) {
  try {
    action();
  } on ScopeRequiredException {
    return;
  }
  throw StateError('Expected a ScopeRequiredException');
}
