import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TaskRepository {
  final ApiService _apiService = ApiService();

  Future<List<Task>> getTasks() async {
    try {
      final response = await _apiService.get('/todos');
      final List<dynamic> data = response.data;
      
      // Take only first 10 tasks for demo
      final tasks = data.take(10).map((json) => Task.fromJson(json)).toList();
      
      // Cache the tasks
      await StorageService.cacheTasks(
        tasks.map((task) => task.toJson()).toList(),
      );
      
      return tasks;
    } catch (e) {
      // Try to load from cache
      final cachedData = StorageService.getCachedTasks();
      if (cachedData != null) {
        return cachedData.map((json) => Task.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _apiService.post('/todos', data: task.toJson());
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await _apiService.put('/todos/${task.id}', data: task.toJson());
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _apiService.delete('/todos/$taskId');
    } catch (e) {
      rethrow;
    }
  }
}
