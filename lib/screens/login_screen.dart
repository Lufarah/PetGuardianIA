import 'package:flutter/material.dart';

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

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_validateCredentials(email, password)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => isLoading = true);
    final result = await authService.loginUser(email: email, password: password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result == null) return;

    _showMessage(result);
  }

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_validateCredentials(email, password)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => isLoading = true);
    final result = await authService.registerUser(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result == null) return;

    _showMessage(result);
  }

  bool _validateCredentials(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Ingresa correo electrónico y contraseña.');
      return false;
    }

    if (!email.contains('@')) {
      _showMessage('Ingresa un correo electrónico válido.');
      return false;
    }

    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
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
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isLoading) _login();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: isLoading ? null : _register,
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
        ),
      ),
    );
  }
}
