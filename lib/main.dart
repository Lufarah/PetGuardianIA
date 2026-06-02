import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = true;
  try {
    await Firebase.initializeApp();
  } catch (_) {
    firebaseReady = false;
  }

  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // La app puede continuar aunque el sistema no permita notificaciones.
  }

  runApp(PetGuardianAI(firebaseReady: firebaseReady));
}

class PetGuardianAI extends StatelessWidget {
  const PetGuardianAI({super.key, this.firebaseReady = true});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetGuardianAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: firebaseReady ? const AuthGate() : const FirebaseErrorScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        return snapshot.data == null ? const LoginScreen() : HomeScreen();
      },
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se pudo inicializar Firebase. Revisa la configuración de la app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
