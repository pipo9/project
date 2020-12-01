

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:asiddharth/components/textfield.dart';
import 'package:asiddharth/controllers/UserController.dart';
import 'package:asiddharth/models/Usermodel.dart';

class Profile extends StatefulWidget {
  final poster;
  Profile({this.poster});
  @override
  _ProfileState createState() => _ProfileState(poster: poster);
}

class _ProfileState extends State<Profile> {
  final poster;
  _ProfileState({this.poster});
  bool loading = false;
  bool enabled = false;
  UserModel _userModel = UserModel();
  UserController controller = UserController();

  @override
  Widget build(BuildContext context) {
    final theuser =
        poster != null ? poster : FirebaseAuth.instance.currentUser.uid;
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return FutureBuilder<DocumentSnapshot>(
        future: controller.getuser(theuser),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Icon(Icons.access_time),
            );
          } else {
            if (snapshot.data != null) {
              final user = snapshot.data.data();
              return ModalProgressHUD(
                inAsyncCall: loading,
                child: Scaffold(
                  backgroundColor: Color(0xffF7F7F7),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (enabled == false) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          content: Stack(
                                              overflow: Overflow.visible,
                                              children: <Widget>[
                                            InteractiveViewer(
                                              child: Container(
                                                  height: _height * 0.3,
                                                  child: Center(
                                                      child: user['image'] !=
                                                              null
                                                          ? Image.network(
                                                              user['image'],
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Icon(
                                                              Icons.person))),
                                            )
                                          ]));
                                    });
                              } else {
                                var x = await controller.getImage();
                                setState(() {
                                  _userModel.fileImage = x;
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: _height * 0.07),
                              height: _width * 0.35,
                              width: _width * 0.35,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.teal),
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(_width * 0.35)),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(_width * 0.35),
                                child: _userModel.fileImage != null ||
                                        user['image'] != null
                                    ? _userModel.fileImage != null
                                        ? Image.file(
                                            _userModel.fileImage,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            user['image'],
                                            fit: BoxFit.cover,
                                          )
                                    : Icon(
                                        Icons.person,
                                        size: _width * 0.3,
                                        color: Colors.teal,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: _height * 0.03,
                          ),
                          Textfields(
                            hintText: "name",
                            icon: Icons.person,
                            labetText: user['name'],
                            enabled: enabled,
                            onChanged: (name) {
                              setState(() {
                                _userModel.username = name;
                              });
                            },
                          ),
                          SizedBox(
                            height: _height * 0.02,
                          ),
                          Textfields(
                              hintText: "email",
                              icon: Icons.email,
                              labetText: user['email'],
                              enabled: enabled,
                              onChanged: (email) {
                                setState(() {
                                  _userModel.useremail = email;
                                });
                              }),
                          SizedBox(
                            height: _height * 0.1,
                          ),
                          theuser == FirebaseAuth.instance.currentUser.uid
                              ? Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          enabled = true;
                                        });
                                      },
                                      child: Container(
                                        height: _height * 0.06,
                                        width: _width * 0.4,
                                        decoration: BoxDecoration(
                                            color: Colors.teal,
                                            borderRadius: BorderRadius.circular(
                                                _width * 0.1)),
                                        child: Padding(
                                          padding: EdgeInsets.all(0).copyWith(
                                              left: _width * 0.03,
                                              right: _width * 0.015),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Edit",
                                                style: GoogleFonts.robotoSlab(
                                                    fontSize: _width * 0.04),
                                              ),
                                              Icon(
                                                Icons.mode_edit,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        if (enabled == true) {
                                          await controller.UpdateuserInfo(
                                              FirebaseAuth
                                                  .instance.currentUser.uid,
                                              _userModel.username != null
                                                  ? _userModel.username
                                                  : user['name'],
                                              _userModel.useremail != null
                                                  ? _userModel.useremail
                                                  : user['email'],
                                              _userModel.fileImage);
                                          setState(() {
                                            enabled = false;
                                            loading = false;
                                          });
                                        } else {}
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: _height * 0.02),
                                        height: _height * 0.06,
                                        width: _width * 0.4,
                                        decoration: BoxDecoration(
                                            color: Colors.teal,
                                            borderRadius: BorderRadius.circular(
                                                _width * 0.1)),
                                        child: Padding(
                                          padding: EdgeInsets.all(0).copyWith(
                                              left: _width * 0.03,
                                              right: _width * 0.015),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Update",
                                                style: GoogleFonts.robotoSlab(
                                                    fontSize: _width * 0.04),
                                              ),
                                              Icon(
                                                Icons.update,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Welcome to my page',
                                  style: GoogleFonts.roboto(
                                      fontSize: _height * 0.03,
                                      color: Colors.teal),
                                ),
                          SizedBox(
                            height: _height * 0.10,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            height: 1,
                            width: _width * 0.15,
                            color: Colors.teal,
                          ),
                          Center(
                            child: Text(
                              "profile",
                              style: GoogleFonts.robotoSlab(
                                  fontSize: _height * 0.02),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: Icon(Icons.access_time),
              );
            }
          }
        });
  }
}
