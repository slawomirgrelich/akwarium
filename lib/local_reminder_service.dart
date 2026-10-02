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
      if (!_ready) {
        debugPrint('Local notification plugin did not initialize.');
        return;
      }
      final permissionResults = <bool?>[
        await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission(),
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true),
        await _notifications
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true),
      ];
      if (permissionResults.contains(false)) {
        _ready = false;
        debugPrint('Local notification permission was denied.');
      }
    } catch (error, stackTrace) {
      _ready = false;
      debugPrint('Local notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> schedule(ScheduledReminder reminder) async {
    if (kIsWeb) return;
    if (!_ready) {
      debugPrint(
        'Could not schedule local reminder ${reminder.id}: notifications are unavailable.',
      );
      return;
    }
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
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule local reminder ${reminder.id}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    if (!_ready) {
      debugPrint(
        'Could not cancel local reminder $id: notifications are unavailable.',
      );
      return;
    }
    try {
      await _notifications.cancel(id);
    } catch (error, stackTrace) {
      debugPrint('Failed to cancel local reminder $id: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class ScheduledReminder {
  const ScheduledReminder({
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
