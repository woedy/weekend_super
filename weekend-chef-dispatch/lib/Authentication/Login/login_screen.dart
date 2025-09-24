import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weekend_chef_dispatch/Authentication/Login/models/sign_in_model.dart';
import 'package:weekend_chef_dispatch/Authentication/Password/forgot_password.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/registration_1.dart';
import 'package:weekend_chef_dispatch/Components/generic_error_dialog_box.dart';
import 'package:weekend_chef_dispatch/Components/generic_loading_dialogbox.dart';
import 'package:weekend_chef_dispatch/Components/generic_success_dialog_box.dart';
import 'package:weekend_chef_dispatch/Components/keyboard_utils.dart';
import 'package:weekend_chef_dispatch/HomePage/HomePage.dart';
import 'package:weekend_chef_dispatch/constants.dart';

Future<SignInModel> signInUser(String email, String password) async {
  final response = await http.post(
    Uri.parse(hostName + "api/accounts/login-dispatch/"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json'
    },
    body: jsonEncode({
      "email": email,
      "password": password,
      "fcm_token": "dsfsdfdsfsdfds",
    }),
  );

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final result = json.decode(response.body);
    if (result != null) {
      print(result['data']['token'].toString());

      await saveIDApiKey(result['data']['token'].toString());
      await saveUserID(result['data']['user_id'].toString());
      await saveEmail(result['data']['email'].toString());

      await saveUserData(result['data']);
    }
    return SignInModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return SignInModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    print(jsonDecode(response.body));
    return SignInModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    print(jsonDecode(response.body));
    return SignInModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to Sign In');
  }
}

Future<bool> saveIDApiKey(String apiKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("API_Key", apiKey);
  return prefs.commit();
}

Future<bool> saveUserID(String user_id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("USER_ID", user_id);
  return prefs.commit();
}

Future<bool> saveEmail(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("EMAIL", email);
  return prefs.commit();
}

Future<void> saveUserData(Map<String, dynamic> userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('user_data', json.encode(userData));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  var show_password = false;

  Future<SignInModel>? _futureSignIn;

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return (_futureSignIn == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: SafeArea(
        //top: false,
        child: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: Colors.black,
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(fontSize: 25),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        'Log in to find your delicious food.',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              labelText: "Email",
                                              labelStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black
                                                      .withOpacity(0.5)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 12.0),

                                              // Add an underline
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: bookDark2),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: bookPrimary),
                                              ),
                                            ),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  225),
                                              PasteTextInputFormatter(),
                                            ],
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Email is required';
                                              }
                                              String pattern =
                                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                                  r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                                  r"{0,253}[a-zA-Z0-9])?)*$";
                                              RegExp regex = RegExp(pattern);
                                              if (!regex.hasMatch(value)) {
                                                return 'Enter a valid email address';
                                              }
                                              return null;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: false,
                                            onSaved: (value) {
                                              setState(() {
                                                email = value;
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              //hintText: 'Enter Password',
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    show_password =
                                                        !show_password;
                                                  });
                                                },
                                                icon: Icon(
                                                  show_password
                                                      ? Icons
                                                          .remove_red_eye_outlined
                                                      : Icons.remove_red_eye,
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              labelText: "Password",
                                              labelStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black
                                                      .withOpacity(0.5)),

                                              contentPadding: const EdgeInsets
                                                  .symmetric(
                                                  vertical: 5.0,
                                                  horizontal:
                                                      12.0), // Adjust the vertical value to change height

                                              // Remove the border and add an underline
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: bookDark2),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: bookPrimary),
                                              ),
                                            ),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  225),
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
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText:
                                                show_password ? false : true,
                                            onSaved: (value) {
                                              setState(() {
                                                password = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            KeyboardUtil.hideKeyboard(context);

                                            _futureSignIn =
                                                signInUser(email!, password!);
                                            //_futureSignIn = signInUser(user!, password!, platformType!);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: bookPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: const Center(
                                            child: Text(
                                              "Login",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      const ForgotPassword()));
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Forgot password? ",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              "Click here to recover",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.3)),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              " ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Fontspring"),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.3)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      const Registration1()));
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Don't have an account? ",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              "Sign up here",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
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
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<SignInModel> buildFutureBuilder() {
    return FutureBuilder<SignInModel>(
        future: _futureSignIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingDialogBox(
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
                      builder: (context) => const HomePageWidget()),
                );

                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      // Show the dialog
                      return const SuccessDialogBox(text: "Login Successful");
                    });
              });
            } else if (data.message == "Errors") {
              String? errorKey = snapshot.data!.errors!.keys.firstWhere(
                (key) => key == "password" || key == "email",
                orElse: () => null!,
              );
              if (errorKey != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));

                  String customErrorMessage =
                      snapshot.data!.errors![errorKey]![0];
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialogBox(text: customErrorMessage);
                      });
                });
              }
            }
          }

          return const LoadingDialogBox(
            text: 'Please Wait..',
          );
        });
  }

  void dispose() {
    super.dispose();
  }
}
