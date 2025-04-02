import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiDebugScreen extends StatefulWidget {
  const ApiDebugScreen({super.key});

  @override
  State<ApiDebugScreen> createState() => _ApiDebugScreenState();
}

class _ApiDebugScreenState extends State<ApiDebugScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(text: 'https://band-api.ch/api/');
  final TextEditingController _tokenController = TextEditingController();
  
  String _responseText = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _makeGetRequest() async {
    setState(() {
      _isLoading = true;
      _responseText = '';
    });

    try {
      final url = Uri.parse(_urlController.text);
      final headers = <String, String>{};
      
      if (_tokenController.text.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_tokenController.text}';
      }
      
      final response = await http.get(url, headers: headers);
      
      setState(() {
        _responseText = '''
Status: ${response.statusCode}
Headers: ${response.headers}
Body: ${_prettyPrintJson(response.body)}
        ''';
      });
    } catch (e) {
      setState(() {
        _responseText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _tryLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _responseText = 'Please enter username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseText = '';
    });

    try {
      final loginUrl = Uri.parse('${_urlController.text}login');
      
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      
      setState(() {
        _responseText = '''
Status: ${response.statusCode}
Headers: ${response.headers}
Body: ${_prettyPrintJson(response.body)}
        ''';

        // Try to extract token
        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final data = json.decode(response.body);
            if (data is Map) {
              final token = data['token'] ?? data['access_token'];
              if (token != null) {
                _tokenController.text = token.toString();
                _responseText += '\n\nToken extracted and set in the token field!';
              }
            }
          } catch (e) {
            _responseText += '\n\nCould not parse response as JSON: $e';
          }
        }
      });
    } catch (e) {
      setState(() {
        _responseText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _prettyPrintJson(String jsonString) {
    try {
      var decodedJson = json.decode(jsonString);
      var encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(decodedJson);
    } catch (e) {
      return jsonString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug Tool'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('API URL', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Enter API URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _tryLogin,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Try Login'),
            ),
            const SizedBox(height: 16),
            
            const Text('Token', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                hintText: 'Auth Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _makeGetRequest,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test API Connection'),
            ),
            const SizedBox(height: 16),
            
            const Text('Response', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(_responseText.isEmpty ? 'No response yet' : _responseText),
            ),
          ],
        ),
      ),
    );
  }
}