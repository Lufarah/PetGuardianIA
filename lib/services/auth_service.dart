import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'No se pudo crear la cuenta.';
    } catch (e) {
      return 'Error inesperado al crear la cuenta: $e';
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'No se pudo iniciar sesión.';
    } catch (e) {
      return 'Error inesperado al iniciar sesión: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
