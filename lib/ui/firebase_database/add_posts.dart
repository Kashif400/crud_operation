import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/utils.dart';
import '../../widgets/round_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final postController = TextEditingController();
  bool loading = false;
  final databaseRef = FirebaseDatabase.instance.ref('Post');
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

  Future UploadImage() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/User/' + DateTime.now().millisecondsSinceEpoch.toString());
    firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);

    Future.value(uploadTask).then((value) async {
      newUrl = await ref.getDownloadURL();
      insertData(newUrl.toString());
    });
  }

  Future<void> insertData(String url) async {
    setState(() {
      loading = true;
    });
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    databaseRef.child(id).set({
      'title': postController.text.toString(),
      'id': id,
      'profile': url
    }).then((value) {
      Utils().toastMessage('Post added');
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
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
                          : Center(child: Icon(Icons.image)),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: postController,
                decoration: InputDecoration(
                    hintText: 'What is in your mind?',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 30,
              ),
              RoundButton(
                  title: 'Add',
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
