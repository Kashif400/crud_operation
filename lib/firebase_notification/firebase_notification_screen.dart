import 'package:crud_operation/firebase_notification/firebase_notication.dart';
import 'package:flutter/material.dart';

class NotificaitonScreen extends StatefulWidget {
  const NotificaitonScreen({super.key});

  @override
  State<NotificaitonScreen> createState() => _NotificaitonScreenState();
}

class _NotificaitonScreenState extends State<NotificaitonScreen> {
  NotificationServices services = NotificationServices();
  @override
  void initState() {
    super.initState();
    services.requestNotificationPermission();
    services.firebaseInit(context);
    services.setupInteractMessage(context);
    services.getDeviceToken().then((value) {
      print('Token...............................................');
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
