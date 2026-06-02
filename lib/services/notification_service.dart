import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
    await _requestAndroidPermissions();

    _initialized = true;
  }

  Future<List<int>> scheduleReminderNotifications({
    required String reminderId,
    required String title,
    required DateTime eventDateTime,
  }) async {
    await initialize();

    final notificationIds = <int>[];
    final notifications = <_ReminderNotification>[
      _ReminderNotification(
        id: _notificationId(reminderId, 'previous-day'),
        scheduledDate: eventDateTime.subtract(const Duration(days: 1)),
        title: 'Mañana: $title',
        body: _formatBody(eventDateTime),
      ),
      _ReminderNotification(
        id: _notificationId(reminderId, 'event-day'),
        scheduledDate: eventDateTime,
        title: 'Hoy: $title',
        body: _formatBody(eventDateTime),
      ),
    ];

    for (final notification in notifications) {
      if (!notification.scheduledDate.isAfter(DateTime.now())) continue;

      await _notifications.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'petguardian_reminders',
            'Recordatorios',
            channelDescription: 'Avisos de eventos de mascotas',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      notificationIds.add(notification.id);
    }

    return notificationIds;
  }

  Future<void> cancelReminderNotifications(Iterable<int> notificationIds) async {
    await initialize();

    for (final notificationId in notificationIds) {
      await _notifications.cancel(notificationId);
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  static int _notificationId(String reminderId, String type) {
    return Object.hash(reminderId, type) & 0x7fffffff;
  }

  static String _formatBody(DateTime eventDateTime) {
    final hour = eventDateTime.hour.toString().padLeft(2, '0');
    final minute = eventDateTime.minute.toString().padLeft(2, '0');

    return 'Tu evento está programado para las $hour:$minute.';
  }
}

class _ReminderNotification {
  const _ReminderNotification({
    required this.id,
    required this.scheduledDate,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime scheduledDate;
  final String title;
  final String body;
}
