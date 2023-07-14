import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../utils/utils.dart';

class ImageUploadFirebaseScreen extends StatefulWidget {
  ImageUploadFirebaseScreen({
    super.key,
  });

  @override
  State<ImageUploadFirebaseScreen> createState() =>
      _ImageUploadFirebaseScreenState();
}

class _ImageUploadFirebaseScreenState extends State<ImageUploadFirebaseScreen> {
  final databaseReference = FirebaseDatabase.instance.ref('images');
  final updateContoller = TextEditingController();

  bool loading = false;

  File? _image;
  final picker = ImagePicker();
  static String? newUrl;

  List<File> _selectedImages = [];

  Future<void> pickImages() async {
    List<File> images = [];

    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        images.add(File(pickedFile.path));
      }
    }

    setState(() {
      _selectedImages = images;
    });
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName');

      await storageReference.putFile(imageFile);

      final imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> uploadImagesToFirebase() async {
    final databaseReference = FirebaseDatabase.instance.ref('images');

    for (var imageFile in _selectedImages) {
      String? imageUrl = await uploadImageToFirebaseStorage(imageFile);

      if (imageUrl != null) {
        databaseReference
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          'image_url': imageUrl,
        }).then((value) {
          Utils().toastMessage('Successful Upload Images');
        }).onError((error, stackTrace) {
          Utils().toastMessage(error.toString());
        });
      }
    }

    print('Upload complete!');
  }

  //single image pick in uplaod firebase storage
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

  // upload firebase
  Future UploadImage(String id) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/User/' + DateTime.now().millisecondsSinceEpoch.toString());
    firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);

    Future.value(uploadTask).then((value) async {
      newUrl = await ref.getDownloadURL();

      databaseReference.child('id').update({'image_url': newUrl});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos')),
      body: Column(children: [
        Text('no'),
        Expanded(
          child: FirebaseAnimatedList(
            query: databaseReference,
            defaultChild: Text('No images'),
            itemBuilder: (context, snapshot, animation, index) {
              if (snapshot.exists) {
                return Expanded(
                    child: Card(
                  child: Column(children: [
                    CachedNetworkImage(
                      height: MediaQuery.sizeOf(context).height * .4,
                      width: MediaQuery.sizeOf(context).width * 1,
                      imageUrl: snapshot.child('image_url').value.toString(),
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              showMyDailog(
                                snapshot.child('id').value.toString(),
                              );
                            },
                            child: Text('Edite')),
                        TextButton(
                            onPressed: () async {
                              await databaseReference
                                  .child(snapshot.child('id').value.toString())
                                  .remove()
                                  .then((value) {
                                Utils().toastMessage('Successful Delete');
                              }).onError((error, stackTrace) {
                                Utils().toastMessage(error.toString());
                              });
                            },
                            child: Text('delete')),
                      ],
                    )
                  ]),
                ));
              } else {
                return Container();
              }
            },
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImages();
          uploadImagesToFirebase();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDailog(
    String id,
  ) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update'),
            content: InkWell(
              onTap: () {
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
            actions: [
              TextButton(
                  onPressed: () async {
                    await UploadImage(id);
                    Navigator.pop(context);
                  },
                  child: Text('Update')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }
}


// Image.network(
//                       snapshot.child('image_url').value.toString(),
//                       fit: BoxFit.cover,
//                     ),