import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/pet_service.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {
  PetListScreen({super.key});

  final PetService petService = PetService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión para ver tus mascotas.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis mascotas'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar mascotas: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pets = snapshot.data!.docs;

          if (pets.isEmpty) {
            return const Center(child: Text('No hay mascotas'));
          }

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final data = pet.data();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.pets,
                    color: Colors.orange,
                  ),
                  title: Text(data['name'] as String? ?? 'Sin nombre'),
                  subtitle: Text(
                    '${data['breed'] ?? 'Sin raza'} - ${data['age'] ?? '0'} años - ${data['weight'] ?? '0'} kg',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailScreen(pet: pet),
                      ),
                    );
                  },
                  trailing: IconButton(
                    onPressed: () async {
                      await petService.deletePet(pet.id);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
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
