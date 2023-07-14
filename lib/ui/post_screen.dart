import 'package:cached_network_image/cached_network_image.dart';
import 'package:crud_operation/ui/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'auth/login_screen.dart';
import 'auth/photos.dart';
import 'firebase_database/add_posts.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Post');
  TextEditingController search = TextEditingController();
  final updateContoller = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageUploadFirebaseScreen()));
            },
            icon: Icon(Icons.image_aspect_ratio),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }).onError((error, stackTrace) {
                Utils().toastMessage(error.toString());
              });
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: search,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: 'Search Name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: FirebaseAnimatedList(
                  query: ref,
                  defaultChild: Text('Loading'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final title = snapshot.child('title').value.toString();
                    if (search.text.isEmpty) {
                      return Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UploadImageScreen(
                                        id: snapshot
                                            .child('id')
                                            .value
                                            .toString(),
                                      ))),
                          child: Card(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(
                                      snapshot
                                          .child('profile')
                                          .value
                                          .toString()),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(snapshot.child('title').value.toString()),
                                Text(snapshot.child('id').value.toString()),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          await ref
                                              .child(snapshot
                                                  .child('id')
                                                  .value
                                                  .toString())
                                              .remove()
                                              .then((value) {
                                            Utils().toastMessage(
                                                'Successful Delete');
                                          }).onError((error, stackTrace) {
                                            Utils()
                                                .toastMessage(error.toString());
                                          });
                                        },
                                        child: Text('delete')),
                                    TextButton(
                                        onPressed: () {
                                          showMyDailog(
                                              title,
                                              snapshot
                                                  .child('id')
                                                  .value
                                                  .toString());
                                        },
                                        child: Text('Edite')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (title
                        .toLowerCase()
                        .contains(search.text.toLowerCase().toLowerCase())) {
                      return Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UploadImageScreen(
                                        id: snapshot
                                            .child('id')
                                            .value
                                            .toString(),
                                      ))),
                          child: Card(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(
                                      snapshot
                                          .child('profile')
                                          .value
                                          .toString()),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(snapshot.child('title').value.toString()),
                                Text(snapshot.child('id').value.toString()),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          await ref
                                              .child(snapshot
                                                  .child('id')
                                                  .value
                                                  .toString())
                                              .remove()
                                              .then((value) {
                                            Utils().toastMessage(
                                                'Successful Delete');
                                          }).onError((error, stackTrace) {
                                            Utils()
                                                .toastMessage(error.toString());
                                          });
                                        },
                                        child: Text('delete')),
                                    TextButton(
                                        onPressed: () {
                                          showMyDailog(
                                              title,
                                              snapshot
                                                  .child('id')
                                                  .value
                                                  .toString());
                                        },
                                        child: Text('Edite')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPostScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDailog(String title, String id) async {
    updateContoller.text = title;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    ref.child(id).update({
                      'title': updateContoller.text.trim(),
                    }).then((value) {
                      loading = false;
                      Utils().toastMessage('Successful Update');
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                      loading = false;
                    });
                  },
                  child: Text('Update')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
            title: Text('Update'),
            content: Container(
              child: TextField(
                controller: updateContoller,
              ),
            ),
          );
        });
  }
}





/*
ListTile(
                    title: Text(snapshot.child('title').value.toString()),
                    subtitle: Text(snapshot.child('id').value.toString()),
                    trailing: PopupMenuButton(
                        color: Colors.white,
                        elevation: 4,
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        icon: Icon(
                          Icons.more_vert,
                        ),
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);

                                      ref
                                          .child(snapshot
                                              .child('id')
                                              .value
                                              .toString())
                                          .update({'title': 'nice world'})
                                          .then((value) {})
                                          .onError((error, stackTrace) {
                                            Utils()
                                                .toastMessage(error.toString());
                                          });
                                    },
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pop(context);

                                    // ref.child(snapshot.child('id').value.toString()).update(
                                    //     {
                                    //       'ttitle' : 'hello world'
                                    //     }).then((value){
                                    //
                                    // }).onError((error, stackTrace){
                                    //   Utils().toastMessage(error.toString());
                                    // });
                                    ref
                                        .child(snapshot
                                            .child('id')
                                            .value
                                            .toString())
                                        .remove()
                                        .then((value) {})
                                        .onError((error, stackTrace) {
                                      Utils().toastMessage(error.toString());
                                    });
                                  },
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Delete'),
                                ),
                              ),
                            ]),
                  );
*/