import 'package:flutter/material.dart';

class ViewPhotoScreen extends StatelessWidget {
  final String image;
  const ViewPhotoScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'image_tag',
        child: InkWell(
          onDoubleTap: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Container(
                width: double.infinity,
                height: 400,
                child: Image.network(image)),
          ),
        ),
      ),
    );
  }
}
