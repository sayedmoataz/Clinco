import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocNotification {
  static AndroidNotificationChannel localNotificationAppChannel =
      const AndroidNotificationChannel(
    'high_importance_channel_clinico', // id
    'High Importance Notifications  For clinico', // title
    importance: Importance.max,
    description: 'This channel is used for clinico important notifications.',
    // importance: Importance.Max,
  );

  static Future init(BuildContext context) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(localNotificationAppChannel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true);
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (value){}
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final user = FirebaseAuth.instance.currentUser;
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        try {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  localNotificationAppChannel.id,
                  localNotificationAppChannel.name,
                  icon: android.smallIcon,
                  channelDescription: localNotificationAppChannel.description,
                  importance: Importance.max,
                  priority: Priority.high,
                  // ongoing: true,
                  styleInformation: const BigTextStyleInformation(''),
                ),
              ));
        } catch (error) {
          print(error);
        }
      }
    });
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }
}
