import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
              // Request permission to send notifications before launching the app
            PermissionStatus status = await Permission.notification.request();

            if (status.isGranted) {
              // Show notification and launch the external app
              await _showNotification();
              launchAnotherApp();
            } else {
              // Handle case where permission is not granted
              print("Permission not granted!");
            }
            //  requestNotificationPermissions();
            // Show notification
            await _showNotification();
            launchAnotherApp();
          },
          child: const Text('Open youtube'),
        ),
      ),
    );
  }

  
// Future<void> requestNotificationPermissions() async {
//    final PermissionStatus status = await Permission.notification.request();
//    if (status.isGranted) {
//       // Notification permissions granted
//    } else if (status.isDenied) {
//       // Notification permissions denied
//    } else if (status.isPermanentlyDenied) {
//       // Notification permissions permanently denied, open app settings
//       await openAppSettings();
//    }
// }
  void launchAnotherApp() async {
    if (!await launchUrl(Uri.parse("https://www.youtube.com"),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch ';
    }
  }

  /// Function to show a notification
  Future<void> _showNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize the plugin for Android and iOS
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a notification for Android and iOS
    const androidDetails = AndroidNotificationDetails(
      'channel_id', // Unique channel ID
      'App Notifications', // Channel name
      channelDescription: 'Notification from the current app',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true, // Ensure sound plays with the notification
      enableVibration: true, // Vibrate with the notification
      visibility: NotificationVisibility.public, // Make it public
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Action Triggered', // Title
      'You have opened YouTube.', // Body
      notificationDetails,
    );
  }
}
