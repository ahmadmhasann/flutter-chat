import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String text) {
  Widget cancelButton = FlatButton(
    color: Color(0xFF4527a0),
    child: Text(
      "Cancel",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop(); // dismiss dialog
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: Color(0xFF313136),
    title: Text(
      title,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    content: Text(
      text,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    actions: [
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
