import 'package:crud_operation/firebase_notification/firebase_notification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'document file/document_upload_screen.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

// top level function for background notification
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('++++++++++++++++++++++++++++++++++++++++++++' +
      message.notification!.title.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      // home: SplashScreen(),
      // home: ImageUploadFirebaseScreen(),
      // home: AddPostScreen(),
      // home: PostScreen(),
      // home: AddPostScreen(),
      // home: const NotificaitonScreen(),
      home: DocumentUploadScreen(),
    );
  }
}
