import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/widgets/main_button.dart';
import 'package:flash_chat/widgets/alert.dart';
import 'package:flutter/services.dart';
import 'package:flash_chat/widgets/main_text.dart';
class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;


  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00695c),
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Color(0xFF0C0C0D),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              MainText(label: 'Email', onChange: (value){
                email = value;
              },),
              SizedBox(
                height: 25.0,
              ),
              MainText(label: 'Password', obscure: true, onChange: (value){
                password = value;
              },),
              SizedBox(
                height: 24.0,
              ),
              MainButton(
                text: 'Login',
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
                            email: email, password: password))
                        .user;
                    if (!user.isEmailVerified) {
                      showAlertDialog(context, 'Verification Rquired',
                          'You need to verify your email address before you login');
                    }
                    if (user != null && user.isEmailVerified) {
                      Navigator.popAndPushNamed(context, ChatScreen.id);

                    }
                  } on PlatformException catch (e) {
                    print(e.code);
                    switch (e.code) {
                      case 'ERROR_INVALID_CREDENTIAL':
                        showAlertDialog(context, 'Invalid Email',
                            'Please enter a valid email or signup');
                        break;
                      case 'ERROR_USER_DISABLED':
                        showAlertDialog(context, 'Disabled Account',
                            'The account you are trying to reach is temporarily disabled. Contact ahmadmhasann@gmail.com for support');
                        break;
                      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
                        showAlertDialog(context, 'Invalid Password',
                            'Please enter a correct password or reset your password');
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
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

