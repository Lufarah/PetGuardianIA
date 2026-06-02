import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {

  PetListScreen({super.key});
  final PetService petService = PetService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        backgroundColor: Colors.teal,
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore.instance
            .collection('pets')
            .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final pets = snapshot.data!.docs;

          if (pets.isEmpty) {

            return const Center(
              child: Text('No hay mascotas'),
            );
          }

          return ListView.builder(

            itemCount: pets.length,

            itemBuilder: (context, index) {

              final pet = pets[index];

              return GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context) =>

                          PetDetailScreen(
                            pet: pet,
                          ),
                    ),
                  );
                },

                child: Card(

                  margin: const EdgeInsets.all(10),

                  child: ListTile(

                    leading: const Icon(
                      Icons.pets,
                      color: Colors.orange,
                    ),

                    title: Text(pet['name']),

                    subtitle: Text(

                      '${pet['breed']} - ${pet['age']} años - ${pet['weight']} kg',
                    ),

                    trailing: IconButton(

                      onPressed: () async {

                        await petService.deletePet(
                          pet.id,
                        );
                      },

                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}