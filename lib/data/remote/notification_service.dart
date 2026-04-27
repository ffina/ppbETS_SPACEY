import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'spacey_channel',
          channelName: 'Spacey Notifications',
          channelDescription: 'General notifications for Spacey',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFFC9A96E),
          ledColor: const Color(0xFFC9A96E),
        ),
        NotificationChannel(
          channelKey: 'spacey_daily',
          channelName: 'Daily Reminder',
          channelDescription: 'Daily journal reminder',
          importance: NotificationImportance.Default,
          defaultColor: const Color(0xFFC9A96E),
        ),
      ],
    );

    // Minta permission
    await AwesomeNotifications().isNotificationAllowed().then((allowed) {
      if (!allowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'spacey_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> scheduleDailyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'spacey_daily',
        title: 'spacey',
        body: 'Hari ini kamu ke mana? Jangan lupa catat! 📸',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 19,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}