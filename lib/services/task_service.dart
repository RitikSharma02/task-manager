import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/task_model.dart';

class TaskService extends GetxService {
  final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000/tasks' : 'http://localhost:3000/tasks';
  final AuthService _authService = Get.find<AuthService>();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Object? body,
    bool isRetry = false,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported method');
    }

    if ((response.statusCode == 401 || response.statusCode == 403) && !isRetry) {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        return _makeRequest(method, endpoint, body: body, isRetry: true);
      }
    }
    
    return response;
  }

  Future<List<Task>> getTasks({int? page, int? limit}) async {
    String query = '';
    if (page != null && limit != null) {
      query = '?page=$page&limit=$limit';
    }
    final response = await _makeRequest('GET', query);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // DEBUG PRINT
      print('DEBUG: getTasks response: $data');

      if (data is List) {
         return data.map((e) => Task.fromJson(e)).toList();
      } else if (data['data'] != null) {
         // API returns { "data": [...], "pagination": {...} }
         return (data['data'] as List).map((e) => Task.fromJson(e)).toList();
      } else if (data['tasks'] != null) {
         return (data['tasks'] as List).map((e) => Task.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load tasks: ${response.body}');
    }
  }

  Future<Task> createTask(String title, String description) async {
    final response = await _makeRequest('POST', '', body: {'title': title, 'description': description});
    print('DEBUG: Create Task Response: ${response.statusCode}');
    print('DEBUG: Body: ${response.body}');


    if (response.statusCode == 201 || response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(String id, Map<String, dynamic> updates) async {
    final response = await _makeRequest('PATCH', '/$id', body: updates);

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await _makeRequest('DELETE', '/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  Future<Task> toggleStatus(String id) async {
    final response = await _makeRequest('PATCH', '/$id/toggle');
    print('DEBUG: toggleStatus response: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
           return Task.fromJson(data['data']);
      }
      return Task.fromJson(data);
    } else {
      throw Exception('Failed to toggle status');
    }
  }
}
