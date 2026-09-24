import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===========================================================================
// 1. Data Model
// ===========================================================================

class Todo {
  final String id;
  final String description;
  final bool completed;

  Todo({
    required this.id,
    required this.description,
    this.completed = false,
  });

  // Important: Override == for comparing Todos in lists (equality check)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          completed == other.completed;

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ completed.hashCode;

  // Helper method to toggle completion status
  Todo copyWith({String? id, String? description, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

// ===========================================================================
// 2. State Management (NotifierProvider)
// ===========================================================================

/// A state management provider using the modern Notifier pattern in Riverpod.
/// Manages the list of todos and exposes CRUD operations.
class TodoListNotifier extends Notifier<List<Todo>> {
  // Initial state: returns an empty list of todos.
  @override
  List<Todo> build() => [];

  // Adds a new todo item to the list.
  void addTodo(String description) {
    final newTodo = Todo(id: DateTime.now().toString(), description: description);
    state = [...state, newTodo];
  }

  // Toggles the completion status of a specific todo.
  void toggleTodo(String todoId) {
    state = state.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(completed: !todo.completed);
      }
      return todo;
    }).toList();
  }

  // Removes a todo item from the list.
  void removeTodo(String todoId) {
    state = state.where((todo) => todo.id != todoId).toList();
  }

  // Toggles the completion status of ALL todo items.
  void toggleAll() {
    final allCompleted = state.every((todo) => todo.completed);
    state = state.map((todo) {
      return todo.copyWith(completed: !allCompleted);
    }).toList();
  }

  // Clears all completed todo items from the list.
  void clearCompleted() {
    state = state.where((todo) => !todo.completed).toList();
  }
}

/// A Riverpod provider that exposes the TodoListNotifier.
/// Using NotifierProvider makes the provider interactive and stateful.
final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

// ===========================================================================
// 3. UI Components
// ===========================================================================

class TodoListApp extends ConsumerStatefulWidget {
  const TodoListApp({super.key});

  @override
  ConsumerState<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends ConsumerState<TodoListApp> {
  final TextEditingController _controller = TextEditingController();
  String? _editId; // Id of the todo currently being edited, null if adding new
  String _editDescription = ''; // Current description being edited

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.watch to listen for state changes in the todoListProvider.
    // This will trigger a rebuild whenever the list of todos changes.
    final todos = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod Todo List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: todos.every((todo) => todo.completed) || todos.isEmpty
                ? null // Disable button if all todos are completed or list is empty
                : () {
                    ref.read(todoListProvider.notifier).clearCompleted();
                  },
            tooltip: "Clear Completed",
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: todos.isEmpty
                ? null // Disable button if list is empty
                : () {
                    ref.read(todoListProvider.notifier).toggleAll();
                  },
            tooltip: todos.every((todo) => todo.completed)
                ? "Unmark All"
                : "Mark All",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInputSection(todos),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text("No todos yet. Add one above!"))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      // Check if this todo is currently being edited
                      if (_editId == todo.id) {
                        return _buildEditItem(todo);
                      } else {
                        return _buildTodoItem(todo);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds the input section for adding or editing todos.
  Widget _buildInputSection(List<Todo> todos) {
    if (_editId == null) {
      // Add mode
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Add Todo",
                  hintText: "What needs to be done?",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () {
                      ref
                          .read(todoListProvider.notifier)
                          .addTodo(_controller.text.trim());
                      _controller.clear();
                    },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      );
    } else {
      // Edit mode
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Edit Todo",
                  hintText: "Update your todo",
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editDescription = value;
                  });
                },
                onSubmitted: (_) => _saveEdit(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveEdit,
              child: const Icon(Icons.save),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _cancelEdit,
              child: const Icon(Icons.cancel),
            ),
          ],
        ),
      );
    }
  }

  /// Saves the edited todo item.
  void _saveEdit() {
    if (_editDescription.trim().isNotEmpty && _editId != null) {
      final index = ref.read(todoListProvider).indexWhere((todo) => todo.id == _editId);
      if (index != -1) {
        // Create a new list with the updated todo
        final updatedTodos = List<Todo>.from(ref.read(todoListProvider));
        updatedTodos[index] = Todo(
          id: _editId!,
          description: _editDescription.trim(),
          completed: updatedTodos[index].completed,
        );
        ref.read(todoListProvider.notifier).state =