import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

const bookPrimary = Color(0xffF94638);
const bookDark = Color(0xffffffff);
const bookDark2 = Color(0xff8E8E8E);
const bookBlack = Color(0xff000000);
const bookWhite = Color(0xffF8F7FC);

const bodyText1 = Color(0xffffffff);
const bodyText2 = Color(0xffffffff);
const clay = Color(0xffa499b3);

const hostNamePROD = "http://92.112.194.239:7575/";
const hostName = "http://192.168.43.121:8000/";
const hostNameMedia = "http://192.168.43.121:8000";

const PUSHER_API = "88ff191e00149bfda666";
const PUSHER_CLUSTER = "mt1";

Future<String?> getApiPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("API_Key");
}

Future<String?> getUserIDPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("USER_ID");
}

Future<String?> getEmailPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("EMAIL");
}

class PasteTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow pasting of text by returning the new value unchanged
    return newValue;
  }
}
