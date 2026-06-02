import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.pets,
              size: 100,
              color: Colors.teal,
            ),

            const SizedBox(height: 20),

            const Text(
              'PetGuardianAI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {

                  String? result = await authService.loginUser(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (result == null) {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );

                  } else {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result),
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () async {

                String? result = await authService.registerUser(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (result == null) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario creado correctamente'),
                    ),
                  );

                } else {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                    ),
                  );
                }
              },

              child: const Text(
                'Crear cuenta',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}