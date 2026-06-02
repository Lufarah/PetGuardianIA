import 'dart:convert';

import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> askAI(String message) async {
    if (_apiKey.isEmpty) {
      return 'Configura la variable GROQ_API_KEY para usar el chat de IA.';
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: const {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un veterinario virtual llamado PetGuardianAI especializado en mascotas. No des diagnósticos médicos definitivos y recomienda visitar un veterinario ante síntomas, urgencias o dudas clínicas.',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 'No se pudo obtener respuesta de la IA (${response.statusCode}).';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return 'La IA no devolvió una respuesta válida.';
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final aiMessage = firstChoice['message'] as Map<String, dynamic>?;
      return aiMessage?['content'] as String? ??
          'La IA no devolvió contenido para mostrar.';
    } catch (e) {
      return 'Error al consultar la IA: $e';
    }
  }
}
