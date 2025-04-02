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
    final response = await http.get(
      Uri.parse('$baseUrl/messages'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Send a message
  Future<Message> sendMessage(String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: _headers,
      body: json.encode({
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  // Get user profile
  Future<ChatUser> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ChatUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  // Login
  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://band-api.ch/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  // Register
  static Future<String> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('https://band-api.ch/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }
}