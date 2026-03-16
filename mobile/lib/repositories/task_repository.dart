import 'package:dio/dio.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskRepository {
  final ApiService _apiService;

  TaskRepository(this._apiService);

  Future<({List<Task> tasks, bool hasMore})> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null && status != 'ALL') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiService.dio.get(
        '/tasks',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final tasks = (data['tasks'] as List).map((t) => Task.fromJson(t)).toList();
      final hasMore = data['pagination']['hasMore'] as bool;

      return (tasks: tasks, hasMore: hasMore);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required String priority,
    required String status,
    DateTime? dueDate,
  }) async {
    try {
      final data = {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'priority': priority,
        'status': status,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      final response = await _apiService.dio.post('/tasks', data: data);
      return Task.fromJson(response.data['data']['task']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
  }) async {
    try {
      final data = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      final response = await _apiService.dio.patch('/tasks/$id', data: data);
      return Task.fromJson(response.data['data']['task']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> toggleTaskStatus(String id) async {
    try {
      final response = await _apiService.dio.patch('/tasks/$id/toggle');
      return Task.fromJson(response.data['data']['task']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null && error.response?.data['message'] != null) {
      return error.response?.data['message'];
    }
    return 'An unexpected error occurred';
  }
}
