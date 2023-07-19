import 'dart:io';

import 'package:crud_operation/document%20file/pdf_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final databaseReference = FirebaseDatabase.instance.ref('pdfs');
  String pdfPath = '';
  String pdfUrl = '';
  // late String pdfUrl;
  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    // if no file is picked
    if (result != null) {
      String file = DateTime.now().millisecondsSinceEpoch.toString() +
          '.' +
          result.files.single.extension!;

      Reference ref = storage.ref().child('pdfs/$file');
      UploadTask uploadTask = ref.putFile(File(result.files.single.path!));

      TaskSnapshot snapshot = await uploadTask;
      pdfUrl = await snapshot.ref.getDownloadURL();
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      PlatformFile fileName = result.files.first;

      if (pdfUrl != null) {
        databaseReference.child(id).set({
          'id': id,
          'file_name': fileName.name.toString(),
          'pdf': pdfUrl,
        }).then((value) {
          Utils().toastMessage('Successful Upload Images');
        }).onError((error, stackTrace) {
          Utils().toastMessage(error.toString());
        });
      }

      // return downloadUrl;
    }

    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
  }

  // Future<File> getFileFromUrl(String url) async {
  //   try {
  //     var data = await http.get(Uri.parse(url));
  //     var bytes = data.bodyBytes;
  //     var dir = await getApplicationDocumentsDirectory();
  //     File file = File("${dir.path}/mypdfonline.pdf");

  //     File urlFile = await file.writeAsBytes(bytes);
  //     pdfPath = urlFile.path;
  //     return urlFile;
  //   } catch (e) {
  //     throw Exception("Error opening url file");
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getFileFromUrl(pdfUrl).then((f) {
    //   setState(() {
    //     pdfPath = f.path;
    //   });
    //   print(pdfPath.toString());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
            child: MaterialButton(
              onPressed: () {
                _pickFile();
              },
              child: Text('Pick File'),
            ),
          ),
          Expanded(
              child: FirebaseAnimatedList(
                  query: databaseReference,
                  itemBuilder: (context, snapshot, animation, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Card(
                          child: InkWell(
                            onTap: () async {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             PdfView(pdfPath: file.path)));
                              if (pdfPath != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfView(
                                            pdfUrl: snapshot
                                                .child('pdf')
                                                .value
                                                .toString())));
                              } else {
                                Container();
                              }
                            },
                            child: ListTile(
                              leading: Icon(Icons.picture_as_pdf),
                              title: Text(
                                  snapshot.child('file_name').value.toString()),
                            ),
                          ),
                        ),
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
