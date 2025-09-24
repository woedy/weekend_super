import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weekend_chef_dispatch/Authentication/Login/login_screen.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/models/sign_up_model.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/registration_1.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/verify_email.dart';
import 'package:weekend_chef_dispatch/Components/generic_error_dialog_box.dart';
import 'package:weekend_chef_dispatch/Components/generic_loading_dialogbox.dart';
import 'package:weekend_chef_dispatch/Components/generic_success_dialog_box.dart';
import 'package:weekend_chef_dispatch/Components/keyboard_utils.dart';
import 'package:weekend_chef_dispatch/constants.dart';

Future<SignUpModel> signUpUser(data) async {
  final url = Uri.parse(hostName + "api/accounts/register-dispatch/");
  final request = http.MultipartRequest('POST', url);

  request.headers['Accept'] = 'application/json';
  request.headers['Content-Type'] = 'multipart/form-data';

  if (data["photo"] != null) {
    request.files
        .add(await http.MultipartFile.fromPath('photo', data["photo"]));
  } else {
    // Handle the case where the photo is null, such as skipping the file addition
    // request.files.add(await http.MultipartFile.fromString('photo', ''));
  }

  request.fields['first_name'] = data["first_name"];
  request.fields['last_name'] = data["last_name"];
  request.fields['email'] = data["email"];
  request.fields['phone'] = data["phone"];
  request.fields['country'] = data["country"];
  request.fields['password'] = data["password"];
  request.fields['password2'] = data["password2"];

  try {
    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final result = json.decode(responseBody);

      print("############");
      print("WE ARE INNNNNNNN");
      print(result);

      await saveIDApiKey(result['data']['token'].toString());
      await saveUserData(result['data']);
      await saveEmail(result['data']['email'].toString());

      return SignUpModel.fromJson(result);
    } else if (response.statusCode == 422 ||
        response.statusCode == 403 ||
        response.statusCode == 400) {
      final responseBody = await response.stream.bytesToString();
      final result = json.decode(responseBody);

      print("############");
      print("ERRORRRRRR");
      print(result);

      return SignUpModel.fromJson(result);
    } else {
      throw Exception('Failed to Sign Up');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to Sign Up');
  }
}

class Password extends StatefulWidget {
  final data;
  const Password({super.key, required this.data});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final _formKey = GlobalKey<FormState>();

  var show_password = false;
  String? password;
  String? password_confirmation;

  Future<SignUpModel>? _futureSignUp;

  @override
  Widget build(BuildContext context) {
    return (_futureSignUp == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      // color: bookWhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Password',
                                style: TextStyle(fontSize: 25),
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Secure your account.',
                                style: TextStyle(fontSize: 12),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    decoration: InputDecoration(
                                      //hintText: 'Enter Password',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            show_password = !show_password;
                                          });
                                        },
                                        icon: Icon(
                                          show_password
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.remove_red_eye,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ),
                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      labelText: "Password",
                                      labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black.withOpacity(0.5)),

                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 5.0,
                                          horizontal:
                                              12.0), // Adjust the vertical value to change height

                                      // Add an underline
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: bookDark2),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: bookPrimary),
                                      ),
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(225),
                                      PasteTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (!RegExp(
                                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#\$%^&*_()\-+=/.,<>?"~`£{}|:;])')
                                          .hasMatch(value)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "- Password must be at least 8 characters long\n- Must include at least one uppercase letter,\n- One lowercase letter, one digit,\n- And one special character",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return '';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                    textInputAction: TextInputAction.next,
                                    obscureText: show_password ? false : true,
                                    onSaved: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      //hintText: 'Enter Password',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            show_password = !show_password;
                                          });
                                        },
                                        icon: Icon(
                                          show_password
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.remove_red_eye,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ),
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      labelText: "Re-Enter Password",
                                      labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black.withOpacity(0.5)),

                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 5.0,
                                          horizontal:
                                              12.0), // Adjust the vertical value to change height

                                      // Add an underline
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: bookDark2),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: bookPrimary),
                                      ),
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(225),
                                      PasteTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value != password) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        password_confirmation = value;
                                      });
                                    },
                                    textInputAction: TextInputAction.next,
                                    obscureText: show_password ? false : true,
                                    onSaved: (value) {
                                      setState(() {
                                        password_confirmation = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            KeyboardUtil.hideKeyboard(context);

                            widget.data['password'] = password.toString();
                            widget.data['password2'] =
                                password_confirmation.toString();
                            print(widget.data);

                            _futureSignUp = signUpUser(widget.data);
                            //_futureSignIn = signInUser(user!, password!, platformType!);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: bookPrimary,
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(
                            child: Text(
                              "Create Account",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  FutureBuilder<SignUpModel> buildFutureBuilder() {
    return FutureBuilder<SignUpModel>(
      future: _futureSignUp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingDialogBox(
            text: 'Please Wait..',
          );
        } else if (snapshot.hasData) {
          var data = snapshot.data!;

          print("#########################");
          //print(data.data!.token!);

          if (data.message == "Successful") {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyEmail(
                    email: widget.data['email'],
                  ),
                ),
              );

              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  // Show the dialog
                  return SuccessDialogBox(text: "Registration Successful");
                },
              );
            });
          } else if (data.message == "Errors") {
            // Gather all error messages and display them
            List<String> errorMessages = [];

            // Loop through all errors and create a list of messages
            if (data.errors != null) {
              data.errors!.forEach((key, value) {
                // Assuming `value` is a list of error messages
                errorMessages.addAll(value);
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Registration1()),
                (route) => false,
              );

              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  // Combine the error messages into a single string
                  String errorText = errorMessages.join("\n");

                  // Show the error dialog with detailed errors
                  return ErrorDialogBox(text: errorText);
                },
              );
            });
          }
        }

        return LoadingDialogBox(
          text: 'Please Wait..',
        );
      },
    );
  }

  void dispose() {
    super.dispose();
  }
}
