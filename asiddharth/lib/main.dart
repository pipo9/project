import 'package:asiddharth/views/HomePage.dart';
import 'package:asiddharth/views/auth/Signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


Widget userLogged() {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null)
    return SignIn();
  else
    return HomePage();
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:userLogged(),
    );
  }
}

