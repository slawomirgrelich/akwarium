import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({required this.authenticatedScreen, super.key});

  final Widget authenticatedScreen;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const LoginScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return authenticatedScreen;
        }

        return const LoginScreen();
      },
    );
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
