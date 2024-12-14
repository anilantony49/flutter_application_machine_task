import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Initialize notifications
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
        if (response.payload == 'open_youtube') {
          _launchYouTube(); // Navigate to YouTube
        }
      },
    );
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Show notification when app is back from background
      _showBackgroundNotification();
    }
  }

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
              _launchYouTube();
            } else {
              // Handle case where permission is not granted
              print("Permission not granted!");
            }
          },
          child: const Text('Open YouTube'),
        ),
      ),
    );
  }

  /// Launch YouTube in an external browser
  void _launchYouTube() async {
    const url = "https://www.youtube.com";
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  /// Function to show a notification
  Future<void> _showNotification() async {
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

    // Show the notification with a payload to identify its action
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Action Triggered', // Title
      'You have opened YouTube.', // Body
      notificationDetails,
      payload: 'open_youtube', // Add a payload to handle the action
    );
  }

  /// Function to show a notification when the app resumes
  Future<void> _showBackgroundNotification() async {
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

    // Show the notification with a payload
    await flutterLocalNotificationsPlugin.show(
      1,
      'Background Notification',
      'YouTube is running in the background.',
      notificationDetails,
      payload: 'open_youtube', // Add payload to handle click
    );
  }
}
