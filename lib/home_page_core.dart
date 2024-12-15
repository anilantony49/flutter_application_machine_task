import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// Controller for the HomePage, manages app lifecycle states and notifications
class HomePageController extends GetxController with WidgetsBindingObserver {
  late final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin; // Plugin for handling local notifications
  bool _appWasInBackground =
      false; // Track if the app was previously in the background

  @override
  void onInit() {
    super.onInit();
    // Add this controller as an observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    initializeNotifications(); // Initialize notification settings
  }

  @override
  void onClose() {
    // Remove this controller as an observer to stop listening to lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is in the background, set the flag to true
      _appWasInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      // Only show notification if the app was previously in the background
      if (_appWasInBackground) {
        _appWasInBackground = false; // Reset flag
        showBackgroundNotification(); // Show a notification
      }
    }
  }

// Initialize notification plugin with Android and iOS settings
  void initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );
// Handle notification actions (e.g., clicking on the notification)
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'open_youtube') {
          launchYouTube(); // Launch YouTube if the payload matches
        }
      },
    );
  }

// Handle the "Open YouTube" action, checking for notification permission
  Future<void> handleOpenYouTube() async {
    final status = await Permission.notification
        .request(); // Request notification permission

    if (status.isGranted) {
      await showNotification(); // Show a notification if permission is granted
      launchYouTube();
    } else {
      // ignore: avoid_print
      print("Permission not granted!");
    }
  }

// Show a notification for an action (e.g., opening YouTube)
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
    // Display the notification with a payload
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Action Triggered',
      'You have opened YouTube.',
      notificationDetails,
      payload: 'open_youtube',
    );
  }

  // Show a notification when the app resumes from the background
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
    // Display the notification with a payload
    await _flutterLocalNotificationsPlugin.show(
      1,
      'Background Notification',
      'YouTube is running in the background.',
      notificationDetails,
      payload: 'open_youtube',
    );
  }

// Launch YouTube in the external browser
  void launchYouTube() async {
    const url = "https://www.youtube.com"; // YouTube URL
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url'; // Handle URL launch failure
    }
  }
}
