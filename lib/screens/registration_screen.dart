import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/widgets/alert.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flash_chat/widgets/main_text.dart';
import 'package:flash_chat/widgets/main_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
class RegistrationScreen extends StatefulWidget {
  static String id = 'regisration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  bool showSpinner = false;
  String email;
  String password;
  String name;
  File image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);

    setState(() {
      image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0C0C0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF00695c),
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 85,
                        backgroundColor: Color(0xFF00695c),
                        child: CircleAvatar(
                          child: image == null
                              ? Icon(
                                  Icons.person_outline,
                                  size: 130,
                                )
                              : null,
                          radius: 80,
                          backgroundImage:
                              image != null ? FileImage(image) : null,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      FlatButton.icon(
                        onPressed: getImage,
                        icon: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.white,
                        ),
                        label: Text(''),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                MainText(
                  label: 'Name',
                  controller: nameController,
                  onChange: (value) {
                    name = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                MainText(
                  label: 'Email',
                  controller: emailController,
                  onChange: (value) {
                    email = value;
                  },
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 30.0,
                ),
                MainText(
                  label: 'Password',
                  controller: passwordController,
                  obscure: true,
                  onChange: (value) {
                    password = value;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                MainButton(
                  text: 'Sign Up',
                  onTap: () async {
                    {
                      if (name == null) {
                        showAlertDialog(
                            context, 'Invalid Data', 'Please enter your name');
                        return;
                      } else if (email == null) {
                        showAlertDialog(
                            context, 'Invalid Data', 'Please enter your email');
                        return;
                      } else if (password == null) {
                        showAlertDialog(context, 'Invalid Data',
                            'Please enter your password');
                        return;
                      } else if (image == null) {
                        showAlertDialog(context, 'Invalid Data',
                            'Please select profile picture');
                        return;
                      }
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        FirebaseUser user =
                            (await _auth.createUserWithEmailAndPassword(
                                    email: email, password: password)).user;
                        await user.sendEmailVerification();
                        final ref = FirebaseStorage.instance.ref().child('user_images').child('${user.uid}.jpg');
                        await ref.putFile(image).onComplete;
                        final url = await ref.getDownloadURL();
                        _firestore.collection('users').add({
                          'name': name,
                          'email': email,
                          'image': url,
                          'id': user.uid,

                        });

                        if (user != null && user.isEmailVerified) {
                          Navigator.popAndPushNamed(context, ChatScreen.id);
                        }
                        if (user != null && !user.isEmailVerified) {
                          showAlertDialog(context, 'Sign Up Successful',
                              'You signed up successfully. Check you mail box at $email to verify your account then login.');
                          nameController.clear();
                          emailController.clear();
                          passwordController.clear();
                          setState(() {
                            image = null;
                          });
                        }
                        } on PlatformException catch (e) {
                        print(e.code);
                        switch (e.code) {
                          case 'ERROR_NETWORK_REQUEST_FAILED':
                            showAlertDialog(context, 'Network Error',
                                'Please make sure you have good internet connection');
                            break;
                          case 'ERROR_WEAK_PASSWORD':
                            showAlertDialog(context, 'Invalid Password',
                                'Please use password with at least 6 characters');
                            break;
                          case 'ERROR_INVALID_EMAIL':
                            showAlertDialog(context, 'Invalid Email',
                                'Please enter a valid email address');
                            break;
                          case 'ERROR_EMAIL_ALREADY_IN_USE':
                            showAlertDialog(context, 'Invalid Email',
                                'The email address $email is already in use');
                            break;
                          default:
                            showAlertDialog(context, 'Error',
                                'An error ocuured. Please try again later or contact ahmadmhasann@gmail.com for support');
                            break;
                        }
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
