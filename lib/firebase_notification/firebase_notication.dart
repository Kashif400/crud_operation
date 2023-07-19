import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:crud_operation/ui/splash_screen.dart';
import 'package:crud_operation/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

//function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    //for android icon use
    var androidInitializationSetting =
        AndroidInitializationSettings('@drawable/app_icon');

    var initializationSettings =
        InitializationSettings(android: androidInitializationSetting);
    await _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (payload) {
      // handle interaction when app is active for android
      handleMessage(context, message);
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user permission provisional');
    } else {
      AppSettings.openAppSettings;
      print('User premission denied ');
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void getTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Refresh Tokeen');
    });
  }

// foreGround notification
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());

      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(1000).toString(),
        'High Importance Notification');
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id, channel.name,
      channelDescription: 'your channel Descriptionn',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/app_icon',
      enableLights: true,
      color: Colors.red, // Replace with your desired background color
      ledColor: Colors.red, // Replace with your desired LED color
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _localNotificationsPlugin.show(0, message.notification!.title.toString(),
          message.notification!.body.toString(), notificationDetails);
    });
  }

//handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  //handle message
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['id'] == '12') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MessageScreen(id: message.data['id'].toString())));
    }
  }
}
