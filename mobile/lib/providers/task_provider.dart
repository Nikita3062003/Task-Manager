import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;

  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String _currentStatusFilter = 'ALL';

  TaskProvider(this._taskRepository);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get currentStatusFilter => _currentStatusFilter;

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _tasks = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    try {
      final result = await _taskRepository.getTasks(
        page: _currentPage,
        limit: 10,
        status: _currentStatusFilter,
      );

      _tasks.addAll(result.tasks);
      _hasMore = result.hasMore;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTask(String title, String? description, String priority, String status) async {
    _setLoading(true);
    try {
      await _taskRepository.createTask(
        title: title,
        description: description,
        priority: priority,
        status: status,
      );
      _error = null;
      _setLoading(false);
      await loadTasks(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTask(String id, String title, String? description, String priority, String status) async {
    _setLoading(true);
    try {
      final updatedTask = await _taskRepository.updateTask(
        id,
        title: title,
        description: description,
        priority: priority,
        status: status,
      );
      
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleTaskStatus(String id) async {
    try {
      final updatedTask = await _taskRepository.toggleTaskStatus(id);
      
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        // If we're filtering by status and the task status changed, we could remove it locally.
        // Or simply pull fresh data. For better UX, we just update the specific task data,
        // and let it show (or we could force a refresh). Let's just update the list.
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setStatusFilter(String status) {
    if (_currentStatusFilter != status) {
      _currentStatusFilter = status;
      loadTasks(refresh: true);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
