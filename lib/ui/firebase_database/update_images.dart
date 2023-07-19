import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/round_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../auth/photos.dart';

class UpdateImages extends StatefulWidget {
  final String imageUrl;
  const UpdateImages({Key? key, required this.imageUrl})
      : super(
          key: key,
        );

  @override
  State<UpdateImages> createState() => _UpdateImagesState();
}

class _UpdateImagesState extends State<UpdateImages> {
  final postController = TextEditingController();
  bool loading = false;
  final databaseReference = FirebaseDatabase.instance.ref('images');
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _image;
  final picker = ImagePicker();
  static String? newUrl;

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image picked');
      }
    });
  }

  late firebase_storage.Reference ref;
  Future UploadImage() async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref('/User/' + id);
      firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);

      Future.value(uploadTask).then((value) async {
        newUrl = await ref.getDownloadURL();

        databaseReference
            .child('id')
            .update({'image_url': newUrl}).then((value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageUploadFirebaseScreen()));
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Images'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () async {
                  getImageGallery();
                },
                child: Container(
                    width: 200,
                    height: 200,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Center(
                        child: _image != null
                            ? Image.file(_image!.absolute)
                            : Image(image: NetworkImage(widget.imageUrl)))),
              ),
              const SizedBox(
                height: 20,
              ),
              RoundButton(
                  title: 'Update',
                  loading: loading,
                  onTap: () {
                    UploadImage();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
