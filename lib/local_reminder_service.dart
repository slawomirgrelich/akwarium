import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Platform adapter for reminders. Web intentionally falls back to in-app UI.
class LocalReminderService {
  LocalReminderService._();

  static final instance = LocalReminderService._();
  final _notifications = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      tz.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Otwórz'),
      );
      _ready = await _notifications.initialize(settings) ?? false;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> schedule(AquariumReminder reminder) async {
    if (!_ready) return;
    try {
      await _notifications.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(reminder.date, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aquarium_tasks',
            'Zadania akwarystyczne',
            channelDescription: 'Przypomnienia o zadaniach akwarium',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // A missing platform permission must not block offline task creation.
    }
  }
}

class AquariumReminder {
  const AquariumReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final int id;
  final String title;
  final String body;
  final DateTime date;
}