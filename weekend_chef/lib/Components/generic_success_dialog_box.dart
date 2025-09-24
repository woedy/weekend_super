import 'package:flutter/material.dart';

class SuccessDialogBox extends StatefulWidget {
  final String text;

  const SuccessDialogBox({Key? key, required this.text}) : super(key: key);

  @override
  State<SuccessDialogBox> createState() => _SuccessDialogBoxState();
}

class _SuccessDialogBoxState extends State<SuccessDialogBox> {
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
             Icon(Icons.check_circle, color: Colors.green, size: 50,),
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
