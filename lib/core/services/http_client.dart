// lib/core/services/http_client.dart - COMPLETE OPTIMIZED VERSION
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClient {
 static final HttpClient _instance = HttpClient._internal();
 factory HttpClient() => _instance;
 HttpClient._internal();

 String? _token;
 late http.Client _client;

 // ✅ Environment configuration from .env
 String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
 int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
 bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
 bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
 String get appName => dotenv.env['APP_NAME'] ?? 'Thiếu Nhi App';
 String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

 // ✅ Initialize HTTP client
 Future<void> init() async {
   _client = http.Client();
   await _loadSavedToken();

   if (debugMode) {
     print('🌐 HttpClient initialized');
     print('🔗 Base URL: $apiBaseUrl');
     print('⏱️ Timeout: ${apiTimeout}ms');
     print('🔧 Debug Mode: ON');
   }
 }

 // ✅ Token management
 Future<void> _loadSavedToken() async {
   try {
     final prefs = await SharedPreferences.getInstance();
     _token = prefs.getString('auth_token');
     if (enableLogging && _token != null) {
       print('🔐 Token loaded from storage');
     }
   } catch (e) {
     if (enableLogging) {
       print('❌ Error loading token: $e');
     }
   }
 }

 Future<void> setToken(String token) async {
   _token = token;
   try {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setString('auth_token', token);
     if (enableLogging) {
       print('🔐 Token saved to storage');
     }
   } catch (e) {
     if (enableLogging) {
       print('❌ Error saving token: $e');
     }
   }
 }

 Future<void> clearToken() async {
   _token = null;
   try {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('auth_token');
     if (enableLogging) {
       print('🗑️ Token cleared from storage');
     }
   } catch (e) {
     if (enableLogging) {
       print('❌ Error clearing token: $e');
     }
   }
 }

 // ✅ Headers configuration
 Map<String, String> get _defaultHeaders => {
       'Content-Type': 'application/json',
       'Accept': 'application/json',
       'User-Agent': '$appName/$appVersion',
       'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
       if (_token != null) 'Authorization': 'Bearer $_token',
     };

 // ✅ URL builder
 String _buildUrl(String endpoint, Map<String, String>? queryParams) {
   final url = endpoint.startsWith('/') ? '$apiBaseUrl$endpoint' : '$apiBaseUrl/$endpoint';

   if (queryParams != null && queryParams.isNotEmpty) {
     final uri = Uri.parse(url);
     final newUri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
     return newUri.toString();
   }

   return url;
 }

 // ✅ HTTP Methods
 Future<ApiResponse> get(String endpoint, {
   Map<String, String>? queryParams,
   Map<String, String>? headers,
 }) async {
   return _makeRequest(
     () => _client.get(
       Uri.parse(_buildUrl(endpoint, queryParams)),
       headers: {..._defaultHeaders, ...?headers},
     ),
     'GET',
     endpoint,
   );
 }

 Future<ApiResponse> post(String endpoint, {
   Map<String, dynamic>? body,
   Map<String, String>? headers,
 }) async {
   return _makeRequest(
     () {
       final requestBody = body != null ? json.encode(body) : null;

       // Log request body for debugging
       if (enableLogging && requestBody != null) {
         print('📤 Request Body: $requestBody');
       }

       return _client.post(
         Uri.parse(_buildUrl(endpoint, null)),
         headers: {..._defaultHeaders, ...?headers},
         body: requestBody,
       );
     },
     'POST',
     endpoint,
   );
 }

 Future<ApiResponse> put(String endpoint, {
   Map<String, dynamic>? body,
   Map<String, String>? headers,
 }) async {
   return _makeRequest(
     () => _client.put(
       Uri.parse(_buildUrl(endpoint, null)),
       headers: {..._defaultHeaders, ...?headers},
       body: body != null ? json.encode(body) : null,
     ),
     'PUT',
     endpoint,
   );
 }

 Future<ApiResponse> patch(String endpoint, {
   Map<String, dynamic>? body,
   Map<String, String>? headers,
 }) async {
   return _makeRequest(
     () => _client.patch(
       Uri.parse(_buildUrl(endpoint, null)),
       headers: {..._defaultHeaders, ...?headers},
       body: body != null ? json.encode(body) : null,
     ),
     'PATCH',
     endpoint,
   );
 }

 Future<ApiResponse> delete(String endpoint, {
   Map<String, String>? headers,
 }) async {
   return _makeRequest(
     () => _client.delete(
       Uri.parse(_buildUrl(endpoint, null)),
       headers: {..._defaultHeaders, ...?headers},
     ),
     'DELETE',
     endpoint,
   );
 }

 // ✅ Core request handler with comprehensive error handling
 Future<ApiResponse> _makeRequest(
   Future<http.Response> Function() request,
   String method,
   String endpoint,
 ) async {
   try {
     if (enableLogging) {
       print('🌐 $method ${_buildUrl(endpoint, null)}');
     }

     final response = await request().timeout(
       Duration(milliseconds: apiTimeout),
       onTimeout: () {
         throw TimeoutException('Request timeout after ${apiTimeout}ms', Duration(milliseconds: apiTimeout));
       },
     );

     if (enableLogging) {
       print('📥 Response: ${response.statusCode}');
       _logResponseBody(response.body);
       print('🔍 Response content-type: ${response.headers['content-type']}');
     }

     return _handleResponse(response);
   } on SocketException {
     return ApiResponse.error(
       'Không có kết nối internet. Vui lòng kiểm tra mạng.',
       'NETWORK_ERROR',
     );
   } on TimeoutException {
     return ApiResponse.error(
       'Kết nối quá chậm. Vui lòng thử lại.',
       'TIMEOUT_ERROR',
     );
   } on HttpException {
     return ApiResponse.error(
       'Lỗi HTTP. Vui lòng thử lại sau.',
       'HTTP_ERROR',
     );
   } on FormatException catch (e) {
     if (enableLogging) {
       print('❌ Format Exception: $e');
     }
     return ApiResponse.error(
       'Dữ liệu từ server không hợp lệ.',
       'FORMAT_ERROR',
     );
   } catch (e) {
     if (enableLogging) {
       print('❌ Request error: $e');
     }
     return ApiResponse.error(
       'Lỗi không xác định. Vui lòng thử lại.',
       'UNKNOWN_ERROR',
     );
   }
 }

 // ✅ Response handler with improved error handling
 ApiResponse _handleResponse(http.Response response) {
   try {
     dynamic data;
     
     if (response.body.isNotEmpty) {
       final contentType = response.headers['content-type'] ?? '';
       
       if (contentType.contains('application/json')) {
         try {
           data = json.decode(response.body);
         } catch (e) {
           if (enableLogging) {
             print('❌ JSON decode error: $e');
             print('❌ Response body: ${response.body}');
           }
           return ApiResponse.error(
             'Server trả về dữ liệu không hợp lệ.',
             'JSON_DECODE_ERROR',
             response.statusCode,
           );
         }
       } else {
         // Handle non-JSON responses (like HTML error pages)
         if (enableLogging) {
           print('⚠️ Non-JSON response detected');
         }
         if (response.statusCode >= 200 && response.statusCode < 300) {
           data = {'message': response.body};
         } else {
           return ApiResponse.error(
             'Server trả về HTML thay vì JSON. Kiểm tra URL API.',
             'NON_JSON_RESPONSE',
             response.statusCode,
           );
         }
       }
     }

     // Handle success responses
     if (response.statusCode >= 200 && response.statusCode < 300) {
       return ApiResponse.success(data);
     }

     // Handle error responses
     String errorMessage = 'Lỗi từ server';
     
     if (data is Map<String, dynamic>) {
       errorMessage = data['message'] ?? 
                    data['error'] ?? 
                    data['details'] ?? 
                    'Lỗi từ server (${response.statusCode})';
     }

     return ApiResponse.error(
       errorMessage,
       'HTTP_${response.statusCode}',
       response.statusCode,
     );
   } catch (e) {
     if (enableLogging) {
       print('❌ Response parsing error: $e');
       print('❌ Response body: "${response.body}"');
     }
     return ApiResponse.error(
       'Lỗi xử lý phản hồi từ server.',
       'PARSE_ERROR',
       response.statusCode,
     );
   }
 }

 // ✅ Helper method to log response body (with size limit)
 void _logResponseBody(String body) {
   if (!enableLogging) return;
   
   const maxLogLength = 1000;
   if (body.length > maxLogLength) {
     print('📄 Response Body (truncated): ${body.substring(0, maxLogLength)}...');
   } else {
     print('📄 Response Body: $body');
   }
 }

 // ✅ Utility methods
 bool get hasToken => _token != null && _token!.isNotEmpty;
 
 String? get currentToken => _token;

 // ✅ Cleanup
 void dispose() {
   _client.close();
 }
}

// ✅ Enhanced API Response class
class ApiResponse {
 final bool isSuccess;
 final dynamic data;
 final String? error;
 final String? errorCode;
 final int? statusCode;

 ApiResponse._({
   required this.isSuccess,
   this.data,
   this.error,
   this.errorCode,
   this.statusCode,
 });

 factory ApiResponse.success(dynamic data) {
   return ApiResponse._(isSuccess: true, data: data);
 }

 factory ApiResponse.error(String error, String errorCode, [int? statusCode]) {
   return ApiResponse._(
     isSuccess: false,
     error: error,
     errorCode: errorCode,
     statusCode: statusCode,
   );
 }

 // ✅ Convenience getters
 bool get isError => !isSuccess;
 bool get isUnauthorized => statusCode == 401;
 bool get isForbidden => statusCode == 403;
 bool get isNotFound => statusCode == 404;
 bool get isServerError => statusCode != null && statusCode! >= 500;
 bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
 bool get isNetworkError => errorCode == 'NETWORK_ERROR' || errorCode == 'TIMEOUT_ERROR';

 // ✅ Helper methods
 T? getData<T>() {
   if (isSuccess && data is T) {
     return data as T;
   }
   return null;
 }

 List<T>? getDataAsList<T>() {
   if (isSuccess && data is List) {
     return (data as List).cast<T>();
   }
   return null;
 }

 Map<String, dynamic>? getDataAsMap() {
   if (isSuccess && data is Map<String, dynamic>) {
     return data as Map<String, dynamic>;
   }
   return null;
 }

 @override
 String toString() {
   if (isSuccess) {
     return 'ApiResponse.success(data: $data)';
   } else {
     return 'ApiResponse.error(error: $error, code: $errorCode, status: $statusCode)';
   }
 }
}

// ✅ Custom timeout exception
class TimeoutException implements Exception {
 final String message;
 final Duration? duration;

 const TimeoutException(this.message, [this.duration]);

 @override
 String toString() => 'TimeoutException: $message';
}