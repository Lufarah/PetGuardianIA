import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reminders =>
      _firestore.collection('reminders');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserReminders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para ver recordatorios.');
    }

    return _reminders
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> addReminder({
    required String title,
    required DateTime dateTime,
    List<int> notificationIds = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para guardar recordatorios.');
    }

    return _reminders.add({
      'userId': user.uid,
      'title': title,
      'date': _formatDate(dateTime),
      'time': _formatTime(dateTime),
      'dateTime': Timestamp.fromDate(dateTime),
      'notificationIds': notificationIds,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateReminder({
    required String reminderId,
    required String title,
    required DateTime dateTime,
    required List<int> notificationIds,
  }) async {
    await _reminders.doc(reminderId).update({
      'title': title,
      'date': _formatDate(dateTime),
      'time': _formatTime(dateTime),
      'dateTime': Timestamp.fromDate(dateTime),
      'notificationIds': notificationIds,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateNotificationIds({
    required String reminderId,
    required List<int> notificationIds,
  }) async {
    await _reminders.doc(reminderId).update({
      'notificationIds': notificationIds,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteReminder(String reminderId) {
    return _reminders.doc(reminderId).delete();
  }

  static String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '${dateTime.year}-$month-$day';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
