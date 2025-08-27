// lib/core/services/auth_service.dart - FIXED USERNAME LOGIN
import '../models/user_model.dart';
import 'http_client.dart';
import 'backend_adapters.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Initialize service
  Future<void> init() async {
    await _httpClient.init();
  }

  // Login - FIXED to use username
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post('/auth/login', body: {
        'username': username, // Đúng field name
        'password': password,
      });

      if (response.isSuccess) {
        final token = response.data['token'];
        final userData = response.data['user'];

        // Save token
        await _httpClient.setToken(token);

        // Parse user
        _currentUser = BackendUserAdapter.fromBackendJson(userData);

        return AuthResult.success(
          user: _currentUser!,
          token: token,
          message: response.data['message'],
        );
      } else {
        return AuthResult.error(response.error ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      return AuthResult.error('Lỗi đăng nhập: ${e.toString()}');
    }
  }

  // Get current user từ server
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _httpClient.get('/auth/me');

      if (response.isSuccess) {
        _currentUser = BackendUserAdapter.fromBackendJson(response.data);
        return _currentUser;
      }

      // Token invalid, clear
      if (response.isUnauthorized) {
        await logout();
      }

      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    if (_currentUser != null) return true;

    final user = await getCurrentUser();
    return user != null;
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _httpClient.post('/auth/change-password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      return response.isSuccess;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint (optional)
      await _httpClient.post('/auth/logout');
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      // Clear local data
      _currentUser = null;
      await _httpClient.clearToken();
    }
  }

  // Create user (Admin only)
  Future<UserModel?> createUser({
    required String username,
    required String password,
    required String role,
    required String fullName,
    String? saintName,
    String? phoneNumber,
    String? address,
    int? departmentId,
    DateTime? birthDate,
  }) async {
    try {
      final response = await _httpClient.post('/users', body: {
        'username': username,
        'password': password,
        'role': role,
        'fullName': fullName,
        'saintName': saintName,
        'phoneNumber': phoneNumber,
        'address': address,
        'departmentId': departmentId,
        'birthDate': birthDate?.toIso8601String(),
      });

      if (response.isSuccess) {
        return BackendUserAdapter.fromBackendJson(response.data);
      }
      return null;
    } catch (e) {
      print('Create user error: $e');
      return null;
    }
  }

  // Get all users (with filters)
  Future<List<UserModel>> getUsers({
    int page = 1,
    int limit = 100,
    String? search,
    String? roleFilter,
    int? departmentId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (roleFilter != null && roleFilter.isNotEmpty) {
        queryParams['roleFilter'] = roleFilter;
      }

      if (departmentId != null) {
        queryParams['departmentFilter'] = departmentId.toString(); // Thêm này
      }

      final response =
          await _httpClient.get('/users', queryParams: queryParams);

      if (response.isSuccess) {
        final users = (response.data['users'] as List)
            .map((json) => BackendUserAdapter.fromBackendJson(json))
            .toList();
        return users;
      }
      return [];
    } catch (e) {
      print('Get users error: $e');
      return [];
    }
  }

  // Update user profile
  Future<UserModel?> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _httpClient.put('/users/$userId', body: updates);

      if (response.isSuccess) {
        final updatedUser = BackendUserAdapter.fromBackendJson(response.data);

        // Update current user if it's the same
        if (_currentUser?.id == userId) {
          _currentUser = updatedUser;
        }

        return updatedUser;
      }
      return null;
    } catch (e) {
      print('Update user error: $e');
      return null;
    }
  }

  // Reset password (Admin)
  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      final response =
          await _httpClient.post('/users/$userId/reset-password', body: {
        'newPassword': newPassword,
      });

      return response.isSuccess;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  // Deactivate user
  Future<bool> deactivateUser(String userId) async {
    try {
      final response = await _httpClient.put('/users/$userId/deactivate');
      return response.isSuccess;
    } catch (e) {
      print('Deactivate user error: $e');
      return false;
    }
  }

  // Get teachers for assignment
  Future<List<UserModel>> getTeachers({String? departmentId}) async {
    try {
      final queryParams = <String, String>{};
      if (departmentId != null) {
        queryParams['departmentId'] = departmentId;
      }

      final response =
          await _httpClient.get('/teachers', queryParams: queryParams);

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => BackendUserAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get teachers error: $e');
      return [];
    }
  }
}

// Result classes
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? token;
  final String? message;
  final String? error;

  AuthResult.success({
    required this.user,
    required this.token,
    this.message,
  })  : isSuccess = true,
        error = null;

  AuthResult.error(this.error)
      : isSuccess = false,
        user = null,
        token = null,
        message = null;

  bool get isError => !isSuccess;
}
