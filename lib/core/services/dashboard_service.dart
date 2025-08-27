// lib/core/services/dashboard_service.dart
import 'http_client.dart';
import '../models/dashboard_overview_model.dart';
import '../models/quick_counts_model.dart';
import '../models/attendance_summary_model.dart';

class DashboardService {
  final HttpClient _httpClient = HttpClient();

  // Singleton
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  /// Get comprehensive dashboard stats
  /// Maps to: GET /api/dashboard/stats
  Future<DashboardOverview> getDashboardOverview() async {
    try {
      final response = await _httpClient.get('/dashboard/stats');

      if (response.isSuccess) {
        return DashboardOverview.fromJson(response.data);
      }

      return DashboardOverview.empty();
    } catch (e) {
      print('Get dashboard overview error: $e');
      return DashboardOverview.empty();
    }
  }

  /// Get quick counts only (lighter API call)
  /// Maps to: GET /api/dashboard/quick-counts
  Future<QuickCounts> getQuickCounts() async {
    try {
      final response = await _httpClient.get('/dashboard/quick-counts');

      if (response.isSuccess) {
        return QuickCounts.fromJson(response.data);
      }

      return QuickCounts.empty();
    } catch (e) {
      print('Get quick counts error: $e');
      return QuickCounts.empty();
    }
  }

  /// Get dashboard stats with role-based filtering
  /// The backend automatically filters based on user's JWT token role
  Future<DashboardOverview> getDashboardStats({String? role}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) {
        queryParams['role'] = role;
      }

      final response = await _httpClient.get(
        '/dashboard/stats',
        queryParams: queryParams,
      );

      if (response.isSuccess) {
        return DashboardOverview.fromJson(response.data);
      }

      return DashboardOverview.empty();
    } catch (e) {
      print('Get dashboard stats error: $e');
      return DashboardOverview.empty();
    }
  }

  /// Get real-time dashboard updates (for auto-refresh)
  Future<DashboardOverview> refreshDashboard() async {
    try {
      // Use quick-counts for faster refresh, then full stats
      final quickCounts = await getQuickCounts();

      if (quickCounts.hasData) {
        // If quick counts work, get full data
        return await getDashboardOverview();
      }

      return DashboardOverview.empty();
    } catch (e) {
      print('Refresh dashboard error: $e');
      return DashboardOverview.empty();
    }
  }

  /// Get attendance summary for today
  Future<AttendanceSummary> getTodayAttendanceSummary() async {
    try {
      final overview = await getDashboardOverview();

      return AttendanceSummary(
        present: overview.presentToday,
        absent: overview.absentToday,
        rate: overview.attendanceRate,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Get today attendance summary error: $e');
      return AttendanceSummary.empty();
    }
  }
}
