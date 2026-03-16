import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<TaskProvider>().loadTasks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TaskProvider>().deleteTask(id).then((success) {
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<TaskProvider>().error ?? 'Failed to delete'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? 'User'}\'s Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => taskProvider.setStatusFilter(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('All Tasks')),
              const PopupMenuItem(value: 'TODO', child: Text('To Do')),
              const PopupMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
              const PopupMenuItem(value: 'DONE', child: Text('Done')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => taskProvider.loadTasks(refresh: true),
        child: taskProvider.tasks.isEmpty && !taskProvider.isLoading
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No tasks found. Create one!')),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: taskProvider.tasks.length + (taskProvider.hasMore ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == taskProvider.tasks.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final task = taskProvider.tasks[i];
                  return TaskCard(
                    task: task,
                    onToggle: () => taskProvider.toggleTaskStatus(task.id),
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(task: task),
                        ),
                      );
                    },
                    onDelete: () => _showDeleteDialog(task.id),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
