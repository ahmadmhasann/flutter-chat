import 'package:flutter/material.dart';
class MainText extends StatelessWidget {
  MainText({
    this.label,  this.obscure = false, this.onChange, this.textInputType, this.controller
  });
  final String label;
  final Function onChange;
  final TextEditingController controller;
  bool obscure;
  TextInputType textInputType =TextInputType.text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
        keyboardType: textInputType,
        style: TextStyle(color: Colors.white),
      cursorColor: Color(0xFF00695c),
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
        ),
        contentPadding:
        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
    );
  }
}
