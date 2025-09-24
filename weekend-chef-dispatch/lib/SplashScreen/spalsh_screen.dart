import 'package:flutter/material.dart';
import 'package:weekend_chef_dispatch/Authentication/Login/login_screen.dart';
import 'package:weekend_chef_dispatch/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/weekend_logo2.png",
                        width: 230,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'We’re thrilled to have you here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        fontSize: 31),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Our mission is to make your experience seamless and enjoyable. \n\nHappy Eating.! 💖',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.black, height: 1, fontSize: 13),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: bookPrimary,
                        borderRadius: BorderRadius.circular(7)),
                    child: Center(
                      child: Text(
                        "Let’s Get Started",
                        style: TextStyle(color: bookWhite),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
