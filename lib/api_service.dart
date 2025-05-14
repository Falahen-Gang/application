import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Update the base URL to ensure it's correct - adjust if needed
  static const String baseUrl = 'http://192.168.1.34:8000/api';
  static const String authUrl = '$baseUrl/auth';
  static const storage = FlutterSecureStorage();
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Save token and user data to secure storage
  static Future<void> _saveAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    await storage.write(key: tokenKey, value: token);
    await storage.write(key: userDataKey, value: jsonEncode(userData));
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await storage.read(key: tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await storage.read(key: userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Clear auth data (logout)
  static Future<void> logout() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: userDataKey);
  }

  // Add authorization header to requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json', // Add Accept header to ensure JSON response
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
        }),
      );

      // Check if response is valid JSON
      if (response.body.trim().startsWith('<')) {
        // Non-JSON response, likely HTML error page
        return {
          'success': false,
          'message':
              'Server returned an invalid response. Please try again later.',
        };
      }

      // Try to parse JSON response
      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Extract token and user data
          final token = data['token'] ?? data['access_token'];
          final userData = data['user'] ?? data;

          // Save auth data
          if (token != null) {
            await _saveAuthData(token, userData);
          }

          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Signup failed',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Failed to parse server response: $e',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Check if response is valid JSON
      if (response.body.trim().startsWith('<')) {
        // Non-JSON response, likely HTML error page
        return {
          'success': false,
          'message':
              'Server returned an invalid response. Please try again later.',
        };
      }

      // Try to parse JSON response
      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Extract token and user data
          final token = data['token'] ?? data['access_token'];
          final userData = data['user'] ?? data;

          // Save auth data
          if (token != null) {
            await _saveAuthData(token, userData);
          }

          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Failed to parse server response: $e',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Add refresh token functionality
  static Future<bool> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$authUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Refresh token response: ${response.statusCode}');
      print('Refresh token body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] ?? data['access_token'];
        if (newToken != null) {
          await storage.write(key: tokenKey, value: newToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Update authenticatedRequest to handle token refresh
  static Future<Map<String, dynamic>> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final token = await getToken();

      print('Making request to endpoint: $endpoint');
      print('Method: $method');
      print('Headers: $headers');
      print('Body: $body');
      print('Token exists: ${token != null}');

      // Determine if endpoint is a full URL or just a path
      final uri =
          endpoint.startsWith('http')
              ? Uri.parse(endpoint)
              : Uri.parse('$baseUrl/$endpoint');

      print('Full URL: $uri');

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return {'success': false, 'message': 'Invalid request method'};
      }

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if response is valid JSON
      if (response.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message':
              'Server returned an invalid response. Status code: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }

      // Try to parse JSON response
      try {
        final data = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'data': data};
        } else {
          // Handle token expiration
          if (response.statusCode == 401) {
            // Try to refresh the token
            final refreshSuccess = await refreshToken();
            if (refreshSuccess) {
              // Retry the request with the new token
              return authenticatedRequest(endpoint, method: method, body: body);
            } else {
              // Token refresh failed, logout
              await logout();
              return {
                'success': false,
                'message': 'Session expired. Please login again.',
                'tokenExpired': true,
              };
            }
          }

          return {
            'success': false,
            'message': data['message'] ?? 'Request failed',
            'data': data,
            'statusCode': response.statusCode,
          };
        }
      } catch (e) {
        print('JSON parsing error: $e');
        return {'success': false, 'message': 'Failed to parse response: $e'};
      }
    } catch (e) {
      print('Network error: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
