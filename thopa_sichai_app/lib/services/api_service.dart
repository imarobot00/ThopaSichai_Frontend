import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Update this with your laptop's IP address
  static const String baseUrl = 'http://192.168.16.112:8000';
  
  // Timeout duration for API requests (important for slow college WiFi)
  static const Duration requestTimeout = Duration(seconds: 10);
  
  // Authentication endpoints
  static const String loginEndpoint = '/api/auth/login/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String profileEndpoint = '/api/auth/profile/';
  static const String logoutEndpoint = '/api/auth/logout/';

  /// Login user with username and password
  /// Returns: {token, user, message} on success
  /// Throws: Exception with error message on failure
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception('Connection timeout. Check your network or try mobile hotspot.');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Invalid username or password');
      } else {
        throw Exception('Login failed (${response.statusCode}). Server may be unreachable.');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot reach server. Check if you\'re on the right network.');
      }
      throw Exception('Network error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Register new user
  /// Returns: {token, user, message} on success
  /// Throws: Exception with error message on failure
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        }),
      ).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception('Connection timeout. Check your network.');
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final errors = jsonDecode(response.body);
        // Extract first error message
        if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List) {
            throw Exception(firstError.first);
          }
          throw Exception(firstError.toString());
        }
        throw Exception('Registration failed');
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get user profile (requires authentication token)
  /// Returns: {id, username, email, first_name, last_name}
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Logout user (requires authentication token)
  /// Deletes the token from server
  static Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ).timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      // Ignore logout errors, we'll clear local token anyway
      print('Logout error: $e');
    }
  }
}
