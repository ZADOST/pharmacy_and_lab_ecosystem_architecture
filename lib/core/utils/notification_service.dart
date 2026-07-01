import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Updated to use the named parameter expected by the newer package version
    await _notificationsPlugin.initialize(
      initializationSettings: initializationSettings,
    );
  }

  static Future<void> showLabResultNotification({
    required int testId,
    required String testName,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lab_results_channel',
      'Lab Results Notifications',
      channelDescription: 'Alerts when laboratory tests are completed',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Updated to strictly map the named parameters
    await _notificationsPlugin.show(
      id: testId,
      title: 'Lab Test Completed',
      body: 'Your results for $testName are now ready to view.',
      notificationDetails: platformChannelSpecifics,
    );
  }
}