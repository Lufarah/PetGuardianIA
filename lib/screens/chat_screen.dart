import 'package:flutter/material.dart';

import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController messageController =
  TextEditingController();

  final AIService aiService = AIService();

  final List<Map<String, String>> messages = [];

  bool isLoading = false;

  Future<void> sendMessage() async {

    if (messageController.text.isEmpty) return;

    final userMessage = messageController.text;

    setState(() {

      messages.add({
        'role': 'user',
        'message': userMessage,
      });

      isLoading = true;
    });

    messageController.clear();

    final aiResponse =
    await aiService.askAI(userMessage);

    setState(() {

      messages.add({
        'role': 'ai',
        'message': aiResponse,
      });

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('PetGuardianAI Chat'),
        backgroundColor: Colors.teal,
      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              padding: const EdgeInsets.all(10),

              itemCount: messages.length,

              itemBuilder: (context, index) {

                final message = messages[index];

                final isUser =
                    message['role'] == 'user';

                return Align(

                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(

                    margin:
                    const EdgeInsets.symmetric(
                      vertical: 5,
                    ),

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(

                      color: isUser
                          ? Colors.teal
                          : Colors.grey[300],

                      borderRadius:
                      BorderRadius.circular(15),
                    ),

                    child: Text(

                      message['message']!,

                      style: TextStyle(

                        color: isUser
                            ? Colors.white
                            : Colors.black,

                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),

          Padding(

            padding: const EdgeInsets.all(10),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: messageController,

                    decoration:
                    const InputDecoration(

                      hintText:
                      'Pregunta sobre mascotas...',

                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(

                  onPressed: sendMessage,

                  icon: const Icon(
                    Icons.send,
                    color: Colors.teal,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}