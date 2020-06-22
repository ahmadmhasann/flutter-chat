import 'package:flutter/material.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/widgets/main_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:flash_chat/widgets/alert.dart';
class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  final _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(
      begin: Colors.blueGrey,
      end: Colors.white,
    ).animate(animationController);
    animationController.forward();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0C0C0D),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset('images/logo.png'),
                height: 150,
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: TypewriterAnimatedTextKit(
                  speed: Duration(milliseconds: 350),
                  repeatForever: false,
                  totalRepeatCount: 1,
                  text: [
                    "Reservoir Chat",
                  ],
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 50.0,
                      fontFamily: "Title"
                  ),
                  textAlign: TextAlign.start,
                  alignment: AlignmentDirectional.topStart // or Alignment.topLeft
              ),
            ),


            SizedBox(
              height: 48.0,
            ),
            MainButton(text: 'Login', onTap: (){
              Navigator.pushNamed(context, LoginScreen.id);
            },),
            MainButton(text: 'Sign Up', onTap: (){
              Navigator.pushNamed(context, RegistrationScreen.id);
            },),
            MainButton(text: 'Open Chat', onTap: () async {
              FirebaseUser firebaseUser = await _auth.currentUser();
              if (firebaseUser != null) {
                Navigator.pushNamed(context, ChatScreen.id);
              } else {
                showAlertDialog(
                    context, 'Login', 'Please Login first');
              }
            },),
          ],
        ),
      ),
    );
  }
}

