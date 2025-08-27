import '../models/class_model.dart';
import 'http_client.dart';
import 'backend_adapters.dart';

class ClassService {
  final HttpClient _httpClient = HttpClient();

  static final ClassService _instance = ClassService._internal();
  factory ClassService() => _instance;
  ClassService._internal();

  Future<List<ClassModel>> getClasses({String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _httpClient.get('/classes', queryParams: queryParams);

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => BackendClassAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get classes error: $e');
      return [];
    }
  }

  Future<ClassModel?> getClassById(String classId) async {
    try {
      final response = await _httpClient.get('/classes/$classId');

      if (response.isSuccess) {
        return BackendClassAdapter.fromBackendJson(response.data);
      }
      return null;
    } catch (e) {
      print('Get class by ID error: $e');
      return null;
    }
  }

  Future<List<ClassModel>> getClassesByDepartment(int departmentId) async {
    try {
      final response = await _httpClient.get('/classes', queryParams: {
        'departmentId': departmentId.toString(),
      });

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => BackendClassAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get classes by department error: $e');
      return [];
    }
  }
}