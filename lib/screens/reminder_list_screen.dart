import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión para ver tus recordatorios.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis recordatorios'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reminders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar recordatorios: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data!.docs;

          if (reminders.isEmpty) {
            return const Center(child: Text('No hay recordatorios'));
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index].data();
              final date = reminder['date'] as String? ?? 'Sin fecha';
              final time = reminder['time'] as String? ?? 'Sin hora';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                  ),
                  title: Text(reminder['title'] as String? ?? 'Sin título'),
                  subtitle: Text('Fecha: $date · Hora: $time'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
