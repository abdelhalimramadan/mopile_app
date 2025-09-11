import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:quit_smoking_app/services/storage_services.dart';
import '../models/models.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // Notification channels
  static const String _motivationChannelId = 'motivation_channel';
  static const String _emergencyChannelId = 'emergency_channel';
  static const String _milestoneChannelId = 'milestone_channel';
  static const String _reminderChannelId = 'reminder_channel';

  // Initialize notification service
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
  }

  // Create notification channels (Android)
  static Future<void> _createNotificationChannels() async {
    const motivationChannel = AndroidNotificationChannel(
      _motivationChannelId,
      'Daily Motivation',
      description: 'Daily motivational messages for quitting smoking',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    const emergencyChannel = AndroidNotificationChannel(
      _emergencyChannelId,
      'Emergency Support',
      description: 'Emergency notifications for craving support',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    const milestoneChannel = AndroidNotificationChannel(
      _milestoneChannelId,
      'Health Milestones',
      description: 'Notifications for health milestone achievements',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      'Daily Reminders',
      description: 'Daily reminders and tips',
      importance: Importance.defaultImportance,
      enableVibration: false,
    );

    final plugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(motivationChannel);
    await plugin?.createNotificationChannel(emergencyChannel);
    await plugin?.createNotificationChannel(milestoneChannel);
    await plugin?.createNotificationChannel(reminderChannel);
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    print('Notification tapped with payload: $payload');

    if (payload != null) {
      if (payload.startsWith('emergency')) {
        // Handle emergency notification
      } else if (payload.startsWith('milestone')) {
        // Handle milestone notification
      } else if (payload.startsWith('motivation')) {
        // Handle motivation notification
      }
    }
  }

  // Request permissions
  static Future<bool> requestPermissions() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (plugin != null) {
      final granted = await plugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final darwinPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (darwinPlugin != null) {
      final granted = await darwinPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = _motivationChannelId,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportanceFromPriority(priority),
      priority: _getPriorityFromPriority(priority),
      icon: '@mipmap/ic_launcher',
      color: Colors.green,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule daily motivational notification
  static Future<void> scheduleDailyMotivation(int hour) async {
    await _notifications.cancel(1000);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      0, // minutes
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _motivationChannelId,
      'Daily Motivation',
      channelDescription: 'Daily motivational messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      1000,
      'Daily Motivation',
      _getRandomMotivationalMessage(),
      scheduledTime,
      notificationDetails,
      payload: 'motivation_daily',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  // Show emergency notification
  static Future<void> showEmergencyNotification() async {
    await showNotification(
      id: 2000,
      title: 'Emergency Support',
      body: 'Craving will pass in 3-5 minutes. Take deep breaths and drink water.',
      payload: 'emergency_craving',
      channelId: _emergencyChannelId,
      priority: NotificationPriority.max,
    );
  }

  // Show milestone achievement
  static Future<void> showMilestoneAchievement(HealthMilestone milestone) async {
    await showNotification(
      id: 3000 + milestone.id.hashCode,
      title: 'New Achievement! 🎉',
      body: '${milestone.title}: ${milestone.description}',
      payload: 'milestone_${milestone.id}',
      channelId: _milestoneChannelId,
      priority: NotificationPriority.high,
    );
  }

  // Show progress update
  static Future<void> showProgressUpdate(ProgressStats stats) async {
    final body = 'You have been smoke-free for ${stats.smokeFreeDays} days! '
        'Saved ${stats.moneySaved.toStringAsFixed(0)} EGP and avoided ${stats.cigarettesAvoided} cigarettes.';

    await showNotification(
      id: 4000,
      title: 'Progress Update',
      body: body,
      payload: 'progress_update',
      channelId: _reminderChannelId,
    );
  }

  // Schedule weekly progress reminder
  static Future<void> scheduleWeeklyProgressReminder() async {
    await _notifications.cancel(5000);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + (7 - now.weekday) % 7, // Next occurrence of the same weekday
      10, // 10 AM
      0,  // 0 minutes
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      'Weekly Progress',
      channelDescription: 'Weekly progress reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      5000,
      'Weekly Progress',
      'Check out your amazing progress this week!',
      scheduledTime,
      notificationDetails,
      payload: 'weekly_progress',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
  // Check and notify for new milestones
  static Future<void> checkAndNotifyMilestones() async {
    final profile = StorageService.getUserProfile();
    if (profile == null) return;

    final stats = StorageService.getProgressStats();
    if (stats == null) return;

    final allMilestones = StorageService.getHealthMilestones();
    final currentMinutes = stats.smokeFreeMinutes;

    for (final milestone in allMilestones) {
      if (currentMinutes >= milestone.minutesFromQuit && !milestone.isAchieved) {
        final updatedMilestone = milestone.copyWith(
          isAchieved: true,
          achievedDate: DateTime.now(),
        );

        await StorageService.updateHealthMilestone(milestone.id, updatedMilestone);
        await showMilestoneAchievement(updatedMilestone);
      }
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Helper methods
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case _motivationChannelId:
        return 'Daily Motivation';
      case _emergencyChannelId:
        return 'Emergency Support';
      case _milestoneChannelId:
        return 'Health Milestones';
      case _reminderChannelId:
        return 'Daily Reminders';
      default:
        return 'General';
    }
  }

  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _motivationChannelId:
        return 'Daily motivational messages for quitting smoking';
      case _emergencyChannelId:
        return 'Emergency notifications for craving support';
      case _milestoneChannelId:
        return 'Notifications for health milestone achievements';
      case _reminderChannelId:
        return 'Daily reminders and tips';
      default:
        return 'General notifications';
    }
  }

  static Importance _getImportanceFromPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  static Priority _getPriorityFromPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  static String _getRandomMotivationalMessage() {
    final messages = [
      'You\'re doing great! Keep up the good work on your smoke-free journey',
      'Every smoke-free day is a new victory',
      'Your body thanks you for this healthy decision',
      'You are stronger than the craving',
      'Think of the money you\'re saving and the health you\'re gaining',
      'Remember why you started this journey',
      'Every breath you take now is cleaner and healthier',
      'You deserve a long and healthy life',
    ];

    return messages[Random().nextInt(messages.length)];
  }
}

enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}
