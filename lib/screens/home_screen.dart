import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'add_pet_screen.dart';
import 'chat_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatelessWidget {

  HomeScreen({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('PetGuardianAI'),

        backgroundColor: Colors.teal,

        actions: [

          IconButton(

            onPressed: () async {

              await authService.logout();

              Navigator.pop(context);
            },

            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Center(

              child: Text(

                'Bienvenido a PetGuardianAI 🐶',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(

              child: Text(

                'Cuida la salud de tus mascotas con IA.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Expanded(

              child: GridView.count(

                crossAxisCount: 2,

                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                children: [

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              AddPetScreen(),
                        ),
                      );
                    },

                    child: _buildMenuCard(

                      Icons.pets,
                      'Mascotas',
                      Colors.orange,
                    ),
                  ),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              ReminderScreen(),
                        ),
                      );
                    },

                    child: _buildMenuCard(

                      Icons.calendar_month,
                      'Calendario',
                      Colors.blue,
                    ),
                  ),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const ChatScreen(),
                        ),
                      );
                    },

                    child: _buildMenuCard(

                      Icons.chat,
                      'Chat IA',
                      Colors.teal,
                    ),
                  ),

                  _buildMenuCard(

                    Icons.medical_services,
                    'Veterinarios',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      IconData icon,
      String title,
      Color color,
      ) {

    return Container(

      decoration: BoxDecoration(

        color: color,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.1),

            blurRadius: 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          Icon(

            icon,

            size: 50,

            color: Colors.white,
          ),

          const SizedBox(height: 15),

          Text(

            title,

            textAlign: TextAlign.center,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 18,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}