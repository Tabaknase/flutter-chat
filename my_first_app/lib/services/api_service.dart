import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/message.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl = 'https://band-api.ch/api';
  final String token;

  ApiService({required this.token});

  // Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMessages: $e');
      throw Exception('Network error: $e');
    }
  }

  // Send a message
  Future<Message> sendMessage(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers,
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get user profile
  Future<ChatUser> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ChatUser.fromJson(json.decode(response.body));
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      throw Exception('Network error: $e');
    }
  }

  // Login
  static Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://band-api.ch/api/login'),  // Adjusted to match your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Adapt this based on your API's actual response structure
        return data['token'] ?? data['access_token'] ?? data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in login: $e');
      throw Exception('Network error: $e');
    }
  }

  // Register
  static Future<String> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://band-api.ch/api/register'),  // Adjusted to match your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        // Adapt this based on your API's actual response structure
        return data['token'] ?? data['access_token'] ?? data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in register: $e');
      throw Exception('Network error: $e');
    }
  }
}