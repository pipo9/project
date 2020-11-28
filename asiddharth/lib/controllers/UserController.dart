import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class UserController {
  final _db = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  File _image;
  String path;
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    path = pickedFile.path;
    _image = File(path);
    return _image;
  }

  Future<Map<String, dynamic>> signup(
      email, password, confpassword, name) async {
    Map<String, dynamic> answer = new Map();
    if (password == confpassword) {
      if (name != null) {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) async {
          await _db
              .collection("users")
              .doc(user.user.uid)
              .set({'name': name, "email": email, 'image': null});
          answer['status'] = true;
          answer['message'] = 'you signed up';
        }).catchError((error) {
          answer['status'] = false;
          answer['message'] = error.message.toString() != 'null'
              ? error.message.toString()
              : "please fill all the forms";
        });
      } else {
        answer['status'] = false;
        answer['message'] = "name should not be empty";
      }
    } else {
      answer['status'] = false;
      answer['message'] = "password should be the same";
    }
    return answer;
  }

  Future<Map<String, dynamic>> login(email, password) async {
    Map<String, dynamic> answer = new Map();
    try {
      var value = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (value != null) {
        answer['status'] = true;
        answer['message'] = 'log-in';
      }
    } on FirebaseAuthException catch (e) {
      answer['status'] = false;
      answer['message'] = e.message.toString();
    }
    return answer;
  }

  logout() {
    _auth.signOut();
  }

  Future<Map<String, dynamic>> resetpassword(email) async {
    Map<String, dynamic> answer = new Map();
    if (email != null) {
      await _auth.sendPasswordResetEmail(email: email).then((value) {
        answer['status'] = true;
        answer['message'] = 'email sent';
      }).catchError((error) {
        answer['status'] = false;
        answer['message'] = error.message.toString();
      });
    } else {
      answer['status'] = false;
      answer['message'] = 'email should not be empty';
    }
    return answer;
  }

  Future<DocumentSnapshot> getuser(id) async {
    final user = _db.collection('users').doc(id).get();
    return user;
  }

  Future UpdateuserInfo(id, name, email, image) async {
    var _uploadedFileURL;
    if (image != null) {
      Reference storageReference = _storage.ref().child('profiles/${Path.basename(_image.path)}');
      UploadTask uploadTask = storageReference.putFile(_image);
      var dowurl = await (await uploadTask).ref.getDownloadURL();
      _uploadedFileURL = dowurl.toString();
      await _db
          .collection('users')
          .doc(id)
          .update({'name': name, 'email': email,'image':_uploadedFileURL});
    }else{
      await _db
          .collection('users')
          .doc(id)
          .update({'name': name, 'email': email});
    }
    await _auth.currentUser.updateEmail(email);
  }
}
