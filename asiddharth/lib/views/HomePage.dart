
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asiddharth/views/post/addPost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:asiddharth/controllers/UserController.dart';
import 'package:asiddharth/controllers/PostController.dart';
import 'package:asiddharth/views/auth/Signin.dart';
import 'post/postview.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  UserController usercontroller = UserController();
  PostController postController = PostController();
  int count = 0;
  bool loading = false;
  List<IconData> icons = [
    Icons.all_inclusive,
    Icons.cloud_download,
    Icons.not_interested
  ];
  List<String> statuss = ['', 'public', 'private'];
  String search = '';
  String status = '';
  List<Color> colors = [Color(0xff004766), Colors.green, Colors.redAccent];
  Map<String, dynamic> user = new Map();
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return StreamBuilder<QuerySnapshot>(
        stream: postController.getallposts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                backgroundColor: Color(0xffF7F7F7),
                body: Center(child: Text('Nothing to show')));
          }
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Color(0xffF7F7F7),
              body: ModalProgressHUD(
                inAsyncCall: loading,
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(_height * 0.01)
                            .copyWith(bottom: _height * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: _width * 0.7,
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    search = value;
                                  });
                                },
                                cursorColor: Colors.black,
                                decoration: new InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: _height * 0.008,
                                        horizontal: _width * 0.045),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                                    hintText: 'search'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                icons[count],
                                color: colors[count],
                              ),
                              iconSize: _height * 0.04,
                              onPressed: () {
                                setState(() {
                                  count = (count + 1) % 3;
                                  print(status = statuss[count]);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Wrap(
                              children: snapshot.data.docs
                                  .map((post) {
                                    if (post
                                            .data()['status']
                                            .contains(status) &&
                                        post
                                            .data()['category']
                                            .contains(search)) {
                                      return GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          user['id'] = post.data()['userid'];
                                          final that = await usercontroller
                                              .getuser(user['id']);
                                          user['image'] = that.data()['image'];
                                          user['name'] = that.data()['name'];
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostView(
                                                          id: post.id,
                                                          user: user)));
                                          setState(() {
                                            loading = false;
                                          });
                                        },
                                        child: Container(
                                          margin:
                                              EdgeInsets.all(_height * 0.005)
                                                  .copyWith(
                                                      bottom: 0, right: 0),
                                          height: _height * 0.25,
                                          width: _width * 0.32,
                                          child: Image(
                                            image: NetworkImage(
                                              post.data()['imagepath'],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: SpeedDial(
                marginRight: 18,
                marginBottom: 20,
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: IconThemeData(size: _height * 0.04),
                overlayColor: Colors.white,
                overlayOpacity: 0.5,
                backgroundColor:Color(0xff004766),
                elevation: 8.0,
                shape: CircleBorder(),
                children: [
                  SpeedDialChild(
                      child: Icon(
                        Icons.person,
                      ),
                      backgroundColor:Color(0xff004766),
                      label: 'profile',
                      labelStyle: TextStyle(fontSize: _width * 0.04),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()))),
                  SpeedDialChild(
                    child: Icon(Icons.add_a_photo),
                    backgroundColor: Color(0xff004766),
                    label: 'add post',
                    labelStyle: TextStyle(fontSize: _width * 0.04),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Post()));
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.open_in_new),
                    backgroundColor: Color(0xff004766),
                    label: 'Log-out',
                    labelStyle: TextStyle(fontSize: _width * 0.04),
                    onTap: () async {
                      setState(() {
                        loading = true;
                      });
                      await usercontroller.logout();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => SignIn()));
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
                backgroundColor: Color(0xffF7F7F7),
                body: Center(child: Text('Nothing to show')));
          }
        });
  }
}
