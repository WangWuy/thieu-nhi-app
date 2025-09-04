// lib/core/services/dashboard_service.dart
import 'http_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final HttpClient _httpClient = HttpClient();

  // Singleton
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  /// Get ALL dashboard data in one call
  /// Maps to: GET /api/dashboard/stats
  Future<DashboardData> getDashboard() async {
    try {
      final response = await _httpClient.get('/dashboard/stats');

      if (response.isSuccess) {
        return DashboardData.fromJson(response.data);
      }

      return DashboardData.empty();
    } catch (e) {
      print('Get dashboard error: $e');
      return DashboardData.empty();
    }
  }
}