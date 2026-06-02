import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReminderListScreen extends StatelessWidget {

  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        backgroundColor: Colors.teal,
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore.instance
            .collection('reminders')
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

          final reminders = snapshot.data!.docs;

          if (reminders.isEmpty) {

            return const Center(
              child: Text('No hay recordatorios'),
            );
          }

          return ListView.builder(

            itemCount: reminders.length,

            itemBuilder: (context, index) {

              final reminder = reminders[index];

              return Card(

                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: const Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                  ),

                  title: Text(reminder['title']),

                  subtitle: Text(
                    'Fecha: ${reminder['date']}',
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