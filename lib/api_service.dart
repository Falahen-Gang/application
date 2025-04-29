import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.34:8000/api/auth';
  static const storage = FlutterSecureStorage();
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Save token and user data to secure storage
  static Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
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
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract token and user data
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'] ?? data;
        
        // Save auth data
        if (token != null) {
          await _saveAuthData(token, userData);
        }
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract token and user data
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'] ?? data;
        
        // Save auth data
        if (token != null) {
          await _saveAuthData(token, userData);
        }
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
  
  // Method to make authenticated requests
  static Future<Map<String, dynamic>> authenticatedRequest(
    String endpoint, 
    {String method = 'GET', Map<String, dynamic>? body}
  ) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      http.Response response;
      
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri, 
            headers: headers,
            body: body != null ? jsonEncode(body) : null
          );
          break;
        case 'PUT':
          response = await http.put(
            uri, 
            headers: headers,
            body: body != null ? jsonEncode(body) : null
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return {'success': false, 'message': 'Invalid request method'};
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        // Handle token expiration
        if (response.statusCode == 401) {
          // Token has expired or is invalid
          await logout(); // Clear stored credentials
          return {'success': false, 'message': 'Session expired. Please login again.', 'tokenExpired': true};
        }
        
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}