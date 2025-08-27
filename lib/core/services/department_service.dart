// lib/core/services/department_service.dart - FIXED VERSION
import '../models/department_model.dart';
import 'http_client.dart';
import 'backend_adapters.dart';

class DepartmentService {
  final HttpClient _httpClient = HttpClient();

  // Singleton
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;
  DepartmentService._internal();

  // Get all departments
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response = await _httpClient.get('/departments');

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => BackendDepartmentAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get departments error: $e');
      return [];
    }
  }

  // Get department statistics
  Future<List<DepartmentStats>> getDepartmentStats() async {
    try {
      final response = await _httpClient.get('/departments/stats');

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => DepartmentStats.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get department stats error: $e');
      return [];
    }
  }

  // ✅ FIX 1: Renamed method to match Dashboard Bloc
  Future<DepartmentStats?> getDepartmentStatsById(String departmentId) async {
    try {
      // ✅ FIX 2: Use general stats endpoint and filter by ID
      final allStats = await getDepartmentStats();
      
      // Find specific department stats
      for (final stat in allStats) {
        if (stat.id == departmentId || stat.name == departmentId) {
          return stat;
        }
      }
      
      // If not found, try direct API call (in case backend adds endpoint later)
      try {
        final response = await _httpClient.get('/departments/$departmentId/stats');
        if (response.isSuccess) {
          return DepartmentStats.fromJson(response.data);
        }
      } catch (e) {
        print('Direct department stats API not available: $e');
      }
      
      return null;
    } catch (e) {
      print('Get department stats by ID error: $e');
      return null;
    }
  }

  // ✅ FIX 3: Remove dashboard methods - use DashboardService instead
  // (Moved to DashboardService to avoid conflicts)
}

// Data classes - ENHANCED with better parsing
class DepartmentStats {
  final String id;
  final String name;
  final String displayName;
  final int totalClasses;
  final int totalTeachers;
  final int totalStudents;

  DepartmentStats({
    required this.id,
    required this.name,
    required this.displayName,
    required this.totalClasses,
    required this.totalTeachers,
    required this.totalStudents,
  });

  factory DepartmentStats.fromJson(Map<String, dynamic> json) {
    return DepartmentStats(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      totalClasses: json['totalClasses'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'totalClasses': totalClasses,
      'totalTeachers': totalTeachers,
      'totalStudents': totalStudents,
    };
  }
}