import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({required this.authenticatedScreen, super.key});

  final Widget authenticatedScreen;

  @override
  Widget build(BuildContext context) {
    try {
      final hasDefaultFirebaseApp = Firebase.apps.any(
        (app) => app.name == defaultFirebaseAppName,
      );
      if (!hasDefaultFirebaseApp) {
        return const LoginScreen();
      }

      final authStateChanges = AuthService().authStateChanges;

      return StreamBuilder<User?>(
        stream: authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const LoginScreen();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _AuthLoadingScreen();
          }

          if (snapshot.hasData) {
            return authenticatedScreen;
          }

          return const LoginScreen();
        },
      );
    } catch (_) {
      return const LoginScreen();
    }
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFE1F5FE)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      ),
    );
  }
}
