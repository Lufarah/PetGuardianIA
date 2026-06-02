import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addReminder({
    required String title,
    required String date,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    await _firestore.collection('reminders').add({

      'userId': user!.uid,
      'title': title,
      'date': date,
      'createdAt': Timestamp.now(),
    });
  }
}