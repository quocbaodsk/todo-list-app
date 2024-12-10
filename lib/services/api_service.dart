import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/api_error.dart';
import '../providers/task_provider.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/api';
  static const String tokenKey = 'access_token';
  String? _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(tokenKey);

    print(_cachedToken);

    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data['data']['token']);
        return data;
      } else {
        throw ApiException(ApiError.fromJson(data));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw ApiException(ApiError.fromJson(data));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw ApiException(ApiError(
            status: 401,
            message: 'Unauthorized'
        ));
      } else {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<void> logout() async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } finally {
      await clearToken();
    }
  }

  // Task APIs
  Future<TaskResponse> getTasks({
    int page = 1,
    String? status,
    String? sortBy,
    String? sortType,
    DateTime? date,
  }) async {
    try {

      final queryParams = {
        'limit': '5',
        'page': page.toString(),
        if (status != null && status != 'all') 'status': status,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortType != null) 'sort_type': sortType,
        if (date != null) 'date': date.toIso8601String(),
      };

      final headers = await getHeaders();
      final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['data'];

        return TaskResponse(
          tasks: (responseData['data'] as List)
              .map((json) => Task.fromJson(json))
              .toList(),
          meta: PaginationMeta.fromJson(responseData['meta']),
        );
      } else {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      print(e);
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Task.fromJson(data['data']);
      } else {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<Task> updateTask(int id, Task task) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data['data']);
      } else {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<void> completeTask(int id, String status) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$id/status'),
        body: json.encode({'status': status}),
        headers: headers,
      );

      print(response.body);

      if (response.statusCode != 200) {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ApiException(ApiError.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiError(
        status: 500,
        message: 'Network error occurred',
      ));
    }
  }
}