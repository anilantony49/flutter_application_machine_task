import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageCore {
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  void initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'open_youtube') {
          launchYouTube();
        }
      },
    );
  }

  Future<void> handleOpenYouTube() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      await showNotification();
      launchYouTube();
    } else {
      // ignore: avoid_print
      print("Permission not granted!");
    }
  }

  Future<void> showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'App Notifications',
      channelDescription: 'Notification from the current app',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Action Triggered',
      'You have opened YouTube.',
      notificationDetails,
      payload: 'open_youtube',
    );
  }

  Future<void> showBackgroundNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'background_channel_id',
      'Background Notifications',
      channelDescription: 'App is running in the background',
      importance: Importance.low,
      priority: Priority.low,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Background Notification',
      'YouTube is running in the background.',
      notificationDetails,
      payload: 'open_youtube',
    );
  }

  void launchYouTube() async {
    const url = "https://www.youtube.com";
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
