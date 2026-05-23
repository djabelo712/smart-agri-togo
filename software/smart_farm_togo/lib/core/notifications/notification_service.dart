import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/cell_model.dart';
import '../firebase/firebase_bootstrap.dart';
import 'background_fcm_handler.dart';

/// Notifications locales + FCM — SmartFarm Togo.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final Set<String> _stressNotifiedCells = {};
  bool _rainNotifiedSession = false;
  bool _initialized = false;

  static const _channelId = 'smartfarm_alerts';
  static const _channelName = 'Alertes champ';
  static const _dailyNotificationId = 100;
  static const _stressIdBase = 200;
  static const _rainNotificationId = 50;
  static const _pumpNotificationId = 51;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Lome'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxInit = LinuxInitializationSettings(
      defaultActionName: 'Ouvrir SmartFarm',
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      linux: linuxInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _local.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Alertes irrigation et capteurs',
          importance: Importance.high,
        ),
      );
      await androidPlugin?.requestNotificationsPermission();
    }

    if (firebaseAvailable) {
      await _setupFcm();
    }

    _initialized = true;
    debugPrint('SmartFarm: notifications initialisées.');
  }

  Future<void> _setupFcm() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await messaging.subscribeToTopic('stress_alert');
        await messaging.subscribeToTopic('pump_alert');
        await messaging.subscribeToTopic('daily_summary');
      }

      FirebaseMessaging.onMessage.listen(_showFcmForeground);

      final token = await messaging.getToken();
      if (kDebugMode && token != null) {
        debugPrint('SmartFarm FCM token: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('SmartFarm: FCM non disponible — $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('SmartFarm: tap notif ${response.payload}');
    }
  }

  Future<void> _showFcmForeground(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'SmartFarm Togo';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Nouvelle alerte';

    await showLocal(
      id: message.hashCode.abs() % 10000 + 1000,
      title: title,
      body: body,
    );
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  Future<void> showLocal({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;
    await _local.show(id, title, body, _details(), payload: payload);
  }

  /// Notifie une fois par zone si Ks < 0,5.
  Future<void> checkStressFromCells({
    required Map<String, FieldCell> cells,
    required bool enabled,
  }) async {
    if (!enabled || !_initialized) return;

    var index = 0;
    for (final cell in cells.values) {
      if (cell.stressKs < 0.5) {
        if (_stressNotifiedCells.contains(cell.id)) continue;
        _stressNotifiedCells.add(cell.id);
        await showLocal(
          id: _stressIdBase + index,
          title: 'Stress hydrique',
          body:
              'Zone ${cell.id} : Ks=${cell.stressKs.toStringAsFixed(2)} (seuil 0,50)',
          payload: 'stress:${cell.id}',
        );
        index++;
      } else {
        _stressNotifiedCells.remove(cell.id);
      }
    }
  }

  Future<void> checkRainAlert({
    required double rainfallMm,
    required bool enabled,
  }) async {
    if (!enabled || !_initialized || rainfallMm <= 0.1) return;
    if (_rainNotifiedSession) return;
    _rainNotifiedSession = true;
    await showLocal(
      id: _rainNotificationId,
      title: 'Pluie détectée',
      body: 'Précipitations : ${rainfallMm.toStringAsFixed(1)} mm — Lomé',
      payload: 'rain',
    );
  }

  Future<void> showPumpAlert({required bool enabled}) async {
    if (!enabled || !_initialized) return;
    await showLocal(
      id: _pumpNotificationId,
      title: 'Panne de pompe',
      body: 'La pompe principale ne répond plus — vérifier le champ',
      payload: 'pump',
    );
  }

  /// Rapport quotidien à 07:00 (Africa/Lome).
  Future<void> scheduleDailySummary({required bool enabled}) async {
    if (!_initialized) return;
    await _local.cancel(_dailyNotificationId);
    if (!enabled) return;

    await _local.zonedSchedule(
      _dailyNotificationId,
      'Rapport quotidien SmartFarm',
      'Résumé irrigation, stress hydrique et météo du champ disponible.',
      _nextSevenAmLome(),
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_summary',
    );
  }

  tz.TZDateTime _nextSevenAmLome() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showTestNotification() async {
    await showLocal(
      id: 9999,
      title: 'Test SmartFarm Togo',
      body: 'Notification de test reçue avec succès.',
      payload: 'test',
    );
  }
}
