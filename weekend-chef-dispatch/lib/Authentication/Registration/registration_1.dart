import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:weekend_chef_dispatch/Authentication/Registration/photo_upload.dart';
import 'package:weekend_chef_dispatch/Components/keyboard_utils.dart';
import 'package:weekend_chef_dispatch/constants.dart';

class Registration1 extends StatefulWidget {
  const Registration1({super.key});

  @override
  State<Registration1> createState() => _Registration1State();
}

class _Registration1State extends State<Registration1> {
  final _formKey = GlobalKey<FormState>();

  FocusNode focusNode = FocusNode();

  String? first_name;
  String? last_name;
  String? phone;
  String? email;
  String? _code;
  String? _number;
  String? country;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      //color: bookWhite,
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
                                'Account Setup',
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
                                "Hey, it's time to tell us about yourself!",
                                style: TextStyle(fontSize: 14),
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
                                        color: Colors.black, fontSize: 14),
                                    decoration: InputDecoration(

                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      labelText: "First name",
                                      labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black.withOpacity(0.5)),

                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 5.0,
                                          horizontal:
                                              12.0), // Adjust the vertical value to change height
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(225),
                                      PasteTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'First name is required';
                                      }
                                      if (value.length < 3) {
                                        return 'First name too short';
                                      }
                                    },
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    onSaved: (value) {
                                      setState(() {
                                        first_name = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),


                                   Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    decoration: InputDecoration(
                                      //hintText: 'Enter Username/Email',

                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      labelText: "Last name",
                                      labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black.withOpacity(0.5)),

                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 5.0,
                                          horizontal:
                                              12.0), // Adjust the vertical value to change height
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(225),
                                      PasteTextInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Last name is required';
                                      }
                                      if (value.length < 3) {
                                        return 'Last name too short';
                                      }
                                    },
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    onSaved: (value) {
                                      setState(() {
                                        last_name = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Contact Number",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  IntlPhoneField(
                                    focusNode: focusNode,
                                    style: const TextStyle(
                                        height: 3,
                                        color: Colors.black,
                                        fontSize: 14),
                                    dropdownIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      // Remove labelText as it was commented out in the original code
                                      // Use UnderlineInputBorder instead of OutlineInputBorder
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.4)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: bookPrimary),
                                      ),
                                      // Remove borderRadius as it's not applicable to UnderlineInputBorder
                                    ),
                                    languageCode: "en",
                                    initialCountryCode: "GH",
                                    validator: (e) {
                                      if (e == null) {
                                        return 'Phone Number required';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _code = value.countryCode.toString();
                                      _number = value.number.toString();
                                      country = value.countryISOCode.toString();
                                    },
                                    onCountryChanged: (country) {},
                                    onSaved: (value) {
                                      setState(() {
                                        _code = value!.countryCode.toString();
                                        _number = value.number.toString();
                                        country =
                                            value.countryISOCode.toString();
                                      });
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    decoration: InputDecoration(
                                      hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black.withOpacity(0.5)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 12.0),

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
                                    textInputAction: TextInputAction.next,
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
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            KeyboardUtil.hideKeyboard(context);

                            phone = _code.toString() + _number.toString();

                            print("##################");
                            print(first_name);
                            print(last_name);
                            print(phone);
                            print(email);
                            print(_code);
                            print(_number);
                            print(country);

                            var data = {
                              "first_name": first_name,
                              "last_name": first_name,
                              "phone": phone,
                              "email": email,
                              "country": country,
                            };

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UploadPhotoReg(
                                          data: data,
                                        )));
                          }

                          //Navigator.push(context, MaterialPageRoute(builder: (context) => UploadPhotoReg()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: bookPrimary,
                              borderRadius: BorderRadius.circular(7)),
                          child: const Center(
                            child: Text(
                              "Next",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
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
}
