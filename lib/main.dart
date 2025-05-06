import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

@riverpod
Future<String> asyncGreeting(AsyncGreetingRef ref) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  return 'Hello, world!';
}

@Riverpod(keepAlive: true)
class CounterNotifier extends _$CounterNotifier {
  @override
  Future<int> build() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 0;
  }

  void increment() async {
    final currentValue = state.valueOrNull;
    if (currentValue == null) {
      return;
    }
    state = const AsyncLoading<int>();
    await Future<void>.delayed(const Duration(seconds: 1));
    state = AsyncValue.data(currentValue + 1);
  }
}

@riverpod
Raw<Future<int>> fakeFirstApi(FakeFirstApiRef ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return 1;
}

@riverpod
Raw<Future<int>> fakeSecondApi(FakeSecondApiRef ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return 2;
}

@riverpod
Future<int> fakeSumApi(FakeSumApiRef ref) async {
  final int firstApiResult = await ref.watch(fakeFirstApiProvider);
  final int secondApiResult = await ref.watch(fakeSecondApiProvider);
  return firstApiResult + secondApiResult;
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String> greeting = ref.watch(asyncGreetingProvider);
    return Center(
      child: greeting.when(
        data: (greet) => Text(greet),
        error: (error, stack) => Text('Error: $error'),
        loading: () => const Text("Loading..."),
      ),
    );
  }
}

class Point {
  Point(this.x, this.y);

  int x;
  int y;
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterNotifierProvider);
    final AsyncValue<String> greet = ref.watch(asyncGreetingProvider);
    final AsyncValue<int> sumApiResult = ref.watch(fakeSumApiProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            greet.when(
              loading: () => const Text('Loading'),
              data: (greet) => Text(greet),
              error: (e, st) => Text(e.toString()),
            ),
            sumApiResult.when(
              loading: () => const Text('Loading'),
              data: (sum) => Text('$sum'),
              error: (e, st) => Text(e.toString()),
            ),
            counter.when(
              loading: () => const Text('Loading'),
              data: (count) => Text('$count'),
              error: (e, st) => Text(e.toString()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterNotifierProvider.notifier).increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
