import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===========================================================================
// 1. Providers
// ===========================================================================

/// Read-only provider (ideal for services, fixed values, or computed values)
final nameProvider = Provider<String>((ref) {
  return "Hirthick";
});

/// Interactive state provider using modern Riverpod Notifier (Riverpod 2 & 3)
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final counterProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

// ===========================================================================
// Main Demo Screen (Basics)
// ===========================================================================

class Basics extends StatelessWidget {
  const Basics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod UI Consumers"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ConsumerWidgetExample(),
          SizedBox(height: 16),
          ConsumerStatefulWidgetExample(),
          SizedBox(height: 16),
          ConsumerBuilderExample(),
        ],
      ),
    );
  }
}

// ===========================================================================
// 1. ConsumerWidget (Equivalent to StatelessWidget)
// ===========================================================================
/// WHEN TO USE:
/// - Your default choice for most screens and UI widgets.
/// - When you don't need lifecycle hooks (initState/dispose) or controllers.
/// - Gives you access to `WidgetRef ref` right in the `build` method.
class ConsumerWidgetExample extends ConsumerWidget {
  const ConsumerWidgetExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch rebuilds this entire widget whenever the provider changes
    final name = ref.watch(nameProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. ConsumerWidget (Stateless)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Hi, $name!"),
            const SizedBox(height: 4),
            const Text(
              "Watches provider directly via 'WidgetRef ref' in build(). Rebuilds whole widget.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 2. ConsumerStatefulWidget (Equivalent to StatefulWidget)
// ===========================================================================
/// WHEN TO USE:
/// - When you need lifecycle hooks (initState, dispose, didUpdateWidget).
/// - When you manage local controllers (TextEditingController, AnimationController, ScrollController).
/// - `ref` is accessible throughout the entire ConsumerState class (not just build!).
class ConsumerStatefulWidgetExample extends ConsumerStatefulWidget {
  const ConsumerStatefulWidgetExample({super.key});

  @override
  ConsumerState<ConsumerStatefulWidgetExample> createState() =>
      _ConsumerStatefulWidgetExampleState();
}

class _ConsumerStatefulWidgetExampleState
    extends ConsumerState<ConsumerStatefulWidgetExample> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Controllers require explicit disposal, making ConsumerStatefulWidget appropriate
    _controller = TextEditingController();

    // Note: `ref` is available in initState, dispose, and helper methods:
    // final initialName = ref.read(nameProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(nameProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "2. ConsumerStatefulWidget (Lifecycle & Controllers)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Provider Value: $name"),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Local Controller Demo",
                hintText: "Type something...",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "`ref` is available globally in State (initState, dispose, etc.).",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 3. Consumer Widget (Granular Rebuilds / Builder)
// ===========================================================================
/// WHEN TO USE:
/// - Fine-grained rebuild optimization: only the child inside builder rebuilds.
/// - Avoids rebuilding large, expensive parent widget trees.
/// - Perfect to wrap inside an existing regular StatelessWidget or StatefulWidget.
class ConsumerBuilderExample extends StatelessWidget {
  const ConsumerBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "3. Consumer Widget (Targeted Rebuilds)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "The parent Card is a regular StatelessWidget that won't rebuild on counter changes.",
            ),
            const SizedBox(height: 12),
            // ONLY this Consumer builder rebuilds when counterProvider changes
            Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(counterProvider);
                return Row(
                  children: [
                    Text(
                      "Counter: $count",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(counterProvider.notifier).increment();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Increment"),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              "Only the row inside Consumer() rebuilds when clicking Increment.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
