import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/task.dart';

class PaginationMeta {
  final int page;
  final int limit;
  final String sortBy;
  final String sortType;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.sortBy,
    required this.sortType,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      sortBy: json['sort_by'] ?? 'id',
      sortType: json['sort_type'] ?? 'desc',
    );
  }
}

class TaskResponse {
  final List<Task> tasks;
  final PaginationMeta meta;

  TaskResponse({
    required this.tasks,
    required this.meta,
  });
}

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _sortBy = 'id';
  String _sortType = 'desc';
  String _filterStatus = 'all';
  DateTime? _filterDate;
  PaginationMeta? _meta;
  int _currentPage = 1;

  List<Task> get tasks => _tasks;

  bool get isLoading => _isLoading;

  bool get hasMore => _tasks.length % (_meta?.limit ?? 10) == 0;

  String get sortBy => _sortBy;

  String get sortType => _sortType;

  int get completedTasksCount =>
      _tasks.where((task) => task.status == 'completed').length;

  Future<void> loadTasks() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _currentPage = 1;
      _tasks = [];
      notifyListeners();

      final response = await _apiService.getTasks(
        page: _currentPage,
        status: _filterStatus,
        sortBy: _sortBy,
        sortType: _sortType,
        date: _filterDate,
      );

      print(response.tasks);

      _tasks = response.tasks;
      _meta = response.meta;
      _currentPage++;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tasks: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getTasks(
        page: _currentPage,
        status: _filterStatus,
        sortBy: _sortBy,
        sortType: _sortType,
        date: _filterDate,
      );

      _tasks.addAll(response.tasks);
      _meta = response.meta;
      _currentPage++;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more tasks: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadTasks();
  }

  Future<void> createTask(Task task) async {
    try {
      final newTask = await _apiService.createTask(task);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    try {
      final newStatus = task.status == 'completed' ? 'pending' : 'completed';
      _tasks[index] = task.copyWith(status: newStatus);
      notifyListeners();
      print(newStatus);
      await _apiService.completeTask(task.id!, newStatus);
    } catch (e) {
      _tasks[index] = oldTask;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    try {
      _tasks[index] = task.copyWith(favorite: !task.favorite);
      notifyListeners();

      await _apiService.updateTask(task.id!, _tasks[index]);
    } catch (e) {
      _tasks[index] = oldTask;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    _tasks.removeAt(index);
    notifyListeners();

    try {
      await _apiService.deleteTask(id);
    } catch (e) {
      _tasks.insert(index, oldTask);
      notifyListeners();
      rethrow;
    }
  }

  void setFilter({String? status, DateTime? date}) {
    if (status != null) _filterStatus = status;
    _filterDate = date;
    loadTasks();
  }

  void setSortBy(String field, bool ascending) {
    _sortBy = field;
    _sortType = ascending ? 'asc' : 'desc';
    loadTasks();
  }

  void resetProvider() {
    _tasks = [];
    _isLoading = false;
    _currentPage = 1;
    _sortBy = 'execution_date';
    _sortType = 'desc';
    _filterStatus = 'all';
    _filterDate = null;
    _meta = null;
    notifyListeners();
  }

  getTaskById(int id) {
    return _tasks.firstWhere((task) => task.id == id);
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _apiService.updateTask(task.id!, task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
