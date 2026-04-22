import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WorkoutTimerNotificationService {
  WorkoutTimerNotificationService._();

  static final WorkoutTimerNotificationService instance =
      WorkoutTimerNotificationService._();

  static const int timerNotificationId = 8801;
  static const String _channelId = 'workout_timer_channel';
  static const String _channelName = 'Workout Timer';
  static const String _channelDescription =
      'Timer completion alerts with sound and vibration';
  static final Int64List _vibrationPattern = Int64List.fromList([
    0,
    500,
    250,
    500,
    250,
    500,
    250,
    500,
    250,
    500,
  ]);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleCompletionAlert({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime scheduledAt = tz.TZDateTime.from(at, tz.local);
    final NotificationDetails details = _alarmNotificationDetails();
    try {
      await _plugin.zonedSchedule(
        timerNotificationId,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (error) {
      if (error.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      await _plugin.zonedSchedule(
        timerNotificationId,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> showCompletionAlert({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      timerNotificationId,
      title,
      body,
      _alarmNotificationDetails(),
    );
  }

  Future<void> cancelTimerAlert() async {
    await _plugin.cancel(timerNotificationId);
  }

  NotificationDetails _alarmNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
        timeoutAfter: 5000,
        autoCancel: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }
}
