import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//👉 Provider

// Used for read-only values

final nameProvider = Provider<String>((ref) {
  return "Hirthick";
});

// 👉 Option A: Using ConsumerStatefulWidget (Best fit for your current Basics class)

// Convert StatefulWidget to ConsumerStatefulWidget and State to ConsumerState. Riverpod provides ref globally across the state class:

class Basics extends ConsumerStatefulWidget {
  const Basics({super.key});

  @override
  ConsumerState<Basics> createState() => _BasicsState();
}

class _BasicsState extends ConsumerState<Basics> {
  @override
  Widget build(BuildContext context) {
    final name = ref.watch(nameProvider);
    return Scaffold(body: Center(child: Text("Hi,$name")));
  }
}

// Option B: Using ConsumerWidget (If you don't need StatefulWidget)
// If your widget doesn't need lifecycle hooks or mutable local state, you can make it a ConsumerWidget. It passes WidgetRef ref directly into build:

// class Basics extends ConsumerWidget {
//   const Basics({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final name = ref.watch(nameProvider);
//     return Scaffold(
//       body: Center(
//         child: Text(name),
//       ),
//     );
//   }
// }

//Option C: Using a Consumer widget (Keep existing widget unchanged)
// If you want to keep your existing

// Basics
//  class as a standard StatefulWidget / StatelessWidget, wrap only the section of the UI that needs the data with a Consumer:

// dart
// class _BasicsState extends State<Basics> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Consumer(
//           builder: (context, ref, child) {
//             final name = ref.watch(nameProvider);
//             return Text(name);
//           },
//         ),
//       ),
//     );
//   }
// }

/// 👉 2. StateProvider (Read & Write)

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the state (rebuilds widget when count changes)
    final count = ref.watch(counterProvider);

    return Scaffold(
      body: Center(child: Text("Count: $count")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 2. Modify the state directly from the UI
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

final counterProvider = StateProvider<int>((ref) => 0);
