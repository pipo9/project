import 'package:asiddharth/controllers/UserController.dart';
import 'package:asiddharth/views/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:asiddharth/controllers/PostController.dart';
import 'package:toast/toast.dart';

import '../HomePage.dart';

class PostView extends StatefulWidget {
  final id;
  final user;
  PostView({@required this.id, this.user});
  @override
  _Poststateview createState() => _Poststateview(id: id, user: user);
}

class _Poststateview extends State<PostView> {
  final id;
  final user;
  _Poststateview({@required this.id, this.user});
  PostController postcontroller = PostController();
  UserController userController = UserController();
  bool loading = false;
  DocumentSnapshot that;

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return FutureBuilder<DocumentSnapshot>(
        future: postcontroller.getpost(id),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Icon(Icons.access_time),
            );
          } else {
            if (snapshot.data != null) {
              final post = snapshot.data.data();
              return Scaffold(
                  backgroundColor: Color(0xffF7F7F7),
                  body: ModalProgressHUD(
                    inAsyncCall: loading,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.all(0).copyWith(
                                    top: _height * 0.01,
                                    bottom: _height * 0.01),
                                height: _height,
                                width: _width,
                                child: Image.network(
                                  post['imagepath'],
                                  fit: BoxFit.fill,
                                )),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Profile(
                                                      poster: user['id'])));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: _width * 0.03),
                                          height: _width * 0.15,
                                          width: _width * 0.15,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.teal),
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      _width * 0.15)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                _width * 0.15),
                                            child: user['image'] != null
                                                ? Image.network(
                                                    user['image'],
                                                    fit: BoxFit.fill,
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    size: _width * 0.08,
                                                    color: Colors.teal,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(0)
                                            .copyWith(left: _width * 0.03),
                                        child: Text(
                                          user['name'],
                                          style: GoogleFonts.robotoSlab(
                                              fontSize: _width * 0.04),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      post["userid"] ==
                                              FirebaseAuth
                                                  .instance.currentUser.uid
                                          ? IconButton(
                                              icon: Icon(Icons.delete_forever),
                                              onPressed: () async {
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomePage()));
                                                final res = await postcontroller
                                                    .deletpost(
                                                        id, post['imagepath']);
                                                setState(() {
                                                  loading = false;
                                                });
                                                Toast.show(
                                                    res['message'], context,
                                                    duration: Toast.LENGTH_LONG,
                                                    gravity: Toast.BOTTOM);
                                              },
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        width: _width * 0.05,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            post['status'] == 'public'
                                                ? Icons.cloud_download
                                                : Icons.not_interested,
                                            color: post['status'] == 'public'
                                                ? Colors.teal
                                                : Colors.deepOrange),
                                        onPressed: () async {
                                          if (post['status'] == 'public') {
                                            final res = await postcontroller
                                                .downloadpostimage(
                                                    post['imagepath']);
                                            Toast.show(res['message'], context,
                                                duration: Toast.LENGTH_LONG,
                                                gravity: Toast.BOTTOM);
                                          } else {
                                            Toast.show(
                                                'this image can not be downloaded',
                                                context,
                                                duration: Toast.LENGTH_LONG,
                                                gravity: Toast.BOTTOM);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ]),
                            SizedBox(
                              height: _height * 0.01,
                            ),
                            Center(
                              child: Text(
                                "description",
                                style: GoogleFonts.robotoSlab(
                                    fontSize: _height * 0.02),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              height: 1,
                              width: _width * 0.15,
                              color: Colors.teal,
                            ),
                            Align(
                              alignment: AlignmentDirectional.bottomStart,
                              child: Padding(
                                padding: EdgeInsets.all(0).copyWith(
                                    left: _width * 0.06,
                                    top: _height * 0.03,
                                    bottom: _height * 0.03),
                                child: Text(
                                  post['description'] != null
                                      ? post['description']
                                      : "no description",
                                  style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: _height * 0.03),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
            } else {
              return Center(
                child: Icon(Icons.access_time),
              );
            }
          }
        });
  }
}
