import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../network/api_exception.dart';
import '../storage/token_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String alertId)? _onNotificationTapCallback;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Set callback for notification tap
  void setNotificationCallback(Function(String alertId) callback) {
    _onNotificationTapCallback = callback;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (kDebugMode) {
      print('Notification tapped: $payload');
    }

    if (payload != null && payload.startsWith('alert_')) {
      final alertId = payload.replaceFirst('alert_', '').split('|').first;
      if (_onNotificationTapCallback != null) {
        _onNotificationTapCallback!(alertId);
      }
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'ai_safety_alerts',
          'AI Safety Alerts',
          channelDescription: 'High priority security alerts',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF06B6D4),
          enableLights: true,
          ledColor: Color(0xFF06B6D4),
          styleInformation: BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Send notification via API (for high priority alerts)
  Future<void> sendApiNotification({
    required String alertId,
    required String title,
    required String message,
    required String priority,
    String? recipientId,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Add authorization if token is available
      final tokenStorage = await TokenStorage.create();
      final token = tokenStorage.accessToken;
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final notificationData = {
        'alert_id': alertId,
        'title': title,
        'message': message,
        'priority': priority.toUpperCase(),
        if (recipientId != null) 'recipient_id': recipientId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await dio.post('/notifications/send', data: notificationData);

      if (kDebugMode) {
        print('API notification sent successfully');
      }
    } on DioException catch (e) {
      final errorMessage = messageFromDioException(e);
      if (kDebugMode) {
        print('Failed to send API notification: $errorMessage');
      }
      throw ApiException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  /// Handle high priority alert - send API notification and show local notification
  Future<void> handleHighPriorityAlert({
    required String alertId,
    required String title,
    required String description,
    required String priority,
    String? cameraId,
    String? recipientId,
    String? imageUrl,
  }) async {
    // Only process high priority alerts
    if (priority.toLowerCase() != 'high' &&
        priority.toLowerCase() != 'critical') {
      return;
    }

    try {
      // Send API notification
      await sendApiNotification(
        alertId: alertId,
        title: title,
        message: description,
        priority: priority,
        recipientId: recipientId,
      );

      // Show local notification
      await showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: '🚨 ${priority.toUpperCase()} Alert',
        body: title,
        payload: 'alert_$alertId|${cameraId ?? ""}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling high priority alert: $e');
      }
      // Fallback: show local notification even if API fails
      await showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: '🚨 ${priority.toUpperCase()} Alert',
        body: title,
        payload: 'alert_$alertId|${cameraId ?? ""}',
      );
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return result ?? true;
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

/// Notification data model
class NotificationData {
  const NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.timestamp,
    this.alertId,
    this.recipientId,
  });

  final String id;
  final String title;
  final String message;
  final String priority;
  final DateTime? timestamp;
  final String? alertId;
  final String? recipientId;

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      alertId: json['alert_id'] as String?,
      recipientId: json['recipient_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority,
      'timestamp': timestamp?.toIso8601String(),
      'alert_id': alertId,
      'recipient_id': recipientId,
    };
  }
}
