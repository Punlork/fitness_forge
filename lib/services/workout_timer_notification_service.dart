import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WorkoutTimerNotificationService {
  WorkoutTimerNotificationService._();

  static final instance = WorkoutTimerNotificationService._();

  static const timerNotificationId = 8801;
  static const _channelId = 'workout_timer_alarm_v2';
  static const _channelName = 'Workout Timer';
  static const _channelDescription =
      'Timer completion alerts with sound and vibration';
  static final Int64List _vibrationPattern = Int64List.fromList([
    0,
    600,
    250,
    600,
    250,
    600,
    250,
    600,
    250,
    600,
    250,
    600,
    250,
    600,
  ]);

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get shouldShowRequest {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return androidPlugin == null;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await initialize();
  }

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
    await _createAndroidChannel();
    await requestPermissions();
    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return;
    }

    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  Future<void> requestPermissions() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      const InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      await _createAndroidChannel();
      _initialized = true;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

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
    await _ensureInitialized();
    final scheduledAt = tz.TZDateTime.from(at, tz.local);
    final details = _alarmNotificationDetails();
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

      // If exact alarms are denied, fall back to inexact scheduling.
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
    await _ensureInitialized();
    await _plugin.show(
      timerNotificationId,
      title,
      body,
      _alarmNotificationDetails(),
    );
  }

  Future<void> cancelTimerAlert() async {
    await _ensureInitialized();
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
        timeoutAfter: 5500,
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
