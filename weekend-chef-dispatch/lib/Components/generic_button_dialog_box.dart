import 'package:flutter/material.dart';

class VerifyDialogBox extends StatelessWidget {
  final Function()? onTapFunction;
  final String loadingText;


  const VerifyDialogBox({
    Key? key,
    required this.loadingText,
    this.onTapFunction,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 350,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), // Border radius of 30
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage("assets/images/confettie-png-ijdv4 1.png")
            )
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "Your Account setup",
                style: TextStyle(fontSize: 48, fontFamily: "Fontspring", height: 1),
              ),
              SizedBox(height: 20),
              Text(
                "Great job! You can always come back and make updates or changes.",
                style: TextStyle(fontSize: 20,),
              ),
/*
              SizedBox(height: 30),

             InkWell(
                onTap: onTapFunction,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: bookPrimary,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(
                    child: Text("Continue to Sign In", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
