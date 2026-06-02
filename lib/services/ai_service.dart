import 'dart:convert';

import 'package:http/http.dart' as http;

class AIService {

  final String apiKey =
      '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';

  Future<String> askAI(String message) async {

    try {

      final response = await http.post(

        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),

        headers: {

          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({

          "model": "llama-3.1-8b-instant",

          "messages": [

            {
              "role": "system",
              "content":
              "Eres un veterinario virtual llamado PetGuardianAI especializado en mascotas.Recuerda no dar diagnostico medico, siempre dile al usuario que para cualquiero diagnostico es recomendable visitar un veterinario"
            },

            {
              "role": "user",
              "content": message
            }
          ]
        }),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      if (data['choices'] != null) {

        return data['choices'][0]['message']['content'];
      }

      return 'Error: ${response.body}';

    } catch (e) {

      return 'Error: $e';
    }
  }
}