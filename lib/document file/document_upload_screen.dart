import 'dart:io';

import 'package:crud_operation/document%20file/pdf_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
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
  bool loading = false;
  // late String pdfUrl;
  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    // progress dialog
    ProgressDialog progressDialog = ProgressDialog(
      context,
      title: const Text('Uploading'),
      message: const Text('Please wait...'),
    );

    // if no file is picked
    if (result != null) {
      progressDialog.show();
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
          Utils().toastMessage('Successful Upload document');
          progressDialog.dismiss();
        }).onError((error, stackTrace) {
          Utils().toastMessage(error.toString());
          progressDialog.dismiss();
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 30,
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
                            onLongPress: () {
                              showMyDailog(
                                  snapshot.child('id').value.toString());
                            },
                            onTap: () async {
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _pickFile();
        },
      ),
    );
  }

  Future<void> showMyDailog(String id) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you want to delete'),
            content: const Text('Delete...'),
            actions: [
              MaterialButton(
                onPressed: () async {
                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Delete'),
                    message: const Text('Please wait'),
                  );

                  progressDialog.show();

                  await databaseReference.child(id).remove().then((value) {
                    Utils().toastMessage('delete document');
                    Navigator.pop(context);
                    progressDialog.dismiss();
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(error.toString());

                    Navigator.pop(context);
                    progressDialog.dismiss();
                  });
                },
                child: Text('Yes'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }
}
