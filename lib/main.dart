import 'package:crud_operation/ui/firebase_database/add_posts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'ui/auth/photos.dart';
import 'ui/post_screen.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
      home: PostScreen(),
      // home: AddPostScreen(),
    );
  }
}
