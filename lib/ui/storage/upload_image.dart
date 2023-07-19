import 'dart:io';
import 'package:crud_operation/ui/storage/photos.dart';
import 'package:crud_operation/utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class UploadImageScreen extends StatefulWidget {
  String? id;
  UploadImageScreen({Key? key, this.id}) : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  List<File> _selectedImages = [];

  Future<void> pickImages() async {
    List<File> images = [];

    final picker = ImagePicker();

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
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      if (imageUrl != null) {
        databaseReference.child(id).set({
          'id': id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        actions: [
          TextButton(
              onPressed: () {
                uploadImagesToFirebase();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageUploadFirebaseScreen()));
              },
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10.0, // Spacing between columns
                mainAxisSpacing: 10.0, // Spacing between rows
              ),
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                return index == 0
                    ? Center(
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            pickImages();
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(_selectedImages[index - 1]))),
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}


// ElevatedButton(
//             onPressed: pickImages,
//             child: Text('Pick Images'),
//           ),
//           ElevatedButton(
//             onPressed: uploadImagesToFirebase,
//             child: Text('Upload Images'),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _selectedImages.length,
//               itemBuilder: (context, index) {
//                 return Image.file(_selectedImages[index]);
//               },
//             ),
//           )