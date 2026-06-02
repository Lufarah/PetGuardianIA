import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const PetGuardianAI());
}

class PetGuardianAI extends StatelessWidget {
  const PetGuardianAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'PetGuardianAI',

      home: const LoginScreen(),
    );
  }
}