import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

enum TaskLoadingState { initial, loading, loaded, error, empty }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  TaskLoadingState _state = TaskLoadingState.initial;
  List<Task> _tasks = [];
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  TaskLoadingState get state => _state;
  List<Task> get tasks => _tasks;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  List<Task> get pendingTasks =>
      _tasks.where((task) => task.status == TaskStatus.pending).toList();
  
  List<Task> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  
  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _state = TaskLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTasks = await _taskRepository.getTasks();
      
      if (refresh) {
        _tasks = newTasks;
      } else {
        _tasks.addAll(newTasks);
      }

      _state = _tasks.isEmpty ? TaskLoadingState.empty : TaskLoadingState.loaded;
      _currentPage++;
      
      // Mock pagination end
      if (_currentPage > 3) {
        _hasMore = false;
      }
    } catch (e) {
      _state = TaskLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createTask(Task task) async {
    try {
      final newTask = await _taskRepository.createTask(task);
      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final updatedTask = await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      
      if (_tasks.isEmpty) {
        _state = TaskLoadingState.empty;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void filterByStatus(TaskStatus? status) {
    // This would filter tasks, for now we just notify
    notifyListeners();
  }
}
