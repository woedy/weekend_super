import 'package:flutter/material.dart';

class ErrorDialogBox extends StatefulWidget {
  final String text;

  const ErrorDialogBox({Key? key, required this.text}) : super(key: key);

  @override
  State<ErrorDialogBox> createState() => _ErrorDialogBoxState();
}

class _ErrorDialogBoxState extends State<ErrorDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 322,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), // Border radius of 30
            color: Colors.white, // Blue color
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Icon(Icons.error, color: Colors.red, size: 50,),
              SizedBox(height: 30), // Spacer
              Text(widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ), // Text
            ],
          ),
        ),
      ),
    );
  }
}
