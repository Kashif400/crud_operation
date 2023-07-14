import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../utils/utils.dart';
import '../upload_image.dart';

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _image!.delete();
  }

  //single image pick in uplaod firebase storage
  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image picked');
      }
    });
  }

  // upload firebase
  late firebase_storage.Reference ref;
  Future UploadImage(String id) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/User/' + DateTime.now().millisecondsSinceEpoch.toString());
      firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);

      Future.value(uploadTask).then((value) async {
        newUrl = await ref.getDownloadURL();

        databaseReference.child('id').update({'image_url': newUrl});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos')),
      body: Column(children: [
        Expanded(
          child: FirebaseAnimatedList(
            query: databaseReference,
            defaultChild: Text('No images'),
            itemBuilder: (context, snapshot, animation, index) {
              if (snapshot.exists) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      CachedNetworkImage(
                        height: MediaQuery.sizeOf(context).height * .4,
                        width: MediaQuery.sizeOf(context).width * 1,
                        imageUrl: snapshot.child('image_url').value.toString(),
                        fit: BoxFit.fill,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                showMyDailog(
                                  snapshot.child('id').value.toString(),
                                  snapshot.child('image_url').value.toString(),
                                );
                              },
                              child: Text('Edite')),
                          TextButton(
                              onPressed: () async {
                                await databaseReference
                                    .child(
                                        snapshot.child('id').value.toString())
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
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UploadImageScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDailog(String id, String images) async {
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
                  child: Expanded(
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