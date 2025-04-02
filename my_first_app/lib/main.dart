import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'api-debug.dart'; // Debug helper

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // Comment/uncomment the next line to toggle between debug screen and normal app
        // home: const ApiDebugScreen(),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  void _toggleAuth() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while checking token
    if (authProvider.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If authenticated, show chat screen
    if (authProvider.isAuthenticated) {
      return const ChatScreen();
    }

    // Otherwise show login or register screen
    return _showLogin
        ? LoginScreen(onRegisterPressed: _toggleAuth)
        : RegisterScreen(onLoginPressed: _toggleAuth);
  }
}