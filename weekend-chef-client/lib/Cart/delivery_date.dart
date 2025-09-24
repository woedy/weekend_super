import 'package:weekend_chef_client/Cart/models/set_order_model.dart';
import 'package:weekend_chef_client/Cart/my_cart.dart';
import 'package:weekend_chef_client/Cart/review_order.dart';
import 'package:weekend_chef_client/Components/generic_error_dialog_box.dart';
import 'package:weekend_chef_client/Components/generic_loading_dialogbox.dart';
import 'package:weekend_chef_client/Components/generic_success_dialog_box.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';
import 'package:http/http.dart' as http;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

Future<SetOrderModel> setOrder(data) async {
  var token = await getApiPref();
  var userId = await getUserIDPref();

  var requestBody = {
    "user_id": userId,
    "chef_id": data['chef_id'],
    "location_id": data['location_id'],
    "day": data['day'],
    "time": data['time'],
    "fast_order": data['fast_order']
  };

  final response = await http.post(
    Uri.parse("${hostName}api/orders/set-order/"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token ' + token.toString()
    },
    body: jsonEncode(requestBody),
  );

  print(response.statusCode);
  if (response.statusCode == 200 || response.statusCode == 201) {
    print(jsonDecode(response.body));
    final result = json.decode(response.body);

    return SetOrderModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return SetOrderModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    print(jsonDecode(response.body));
    return SetOrderModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    print(jsonDecode(response.body));
    return SetOrderModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 401) {
    print(jsonDecode(response.body));
    return SetOrderModel.fromJson(jsonDecode(response.body));
  } else {
    //throw Exception('Failed to load data');
    print(jsonDecode(response.body));
    return SetOrderModel.fromJson(jsonDecode(response.body));
  }
}

class SelectDayTimeWidget extends StatefulWidget {
  final selected_chef;
  final client_location;
  const SelectDayTimeWidget(
      {super.key, required this.selected_chef, required this.client_location});

  @override
  State<SelectDayTimeWidget> createState() => _SelectDayTimeWidgetState();
}

class _SelectDayTimeWidgetState extends State<SelectDayTimeWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedDay = 'Saturday'; // Default to Saturday
  String selectedTime = ''; // Initially, no time is selected.
  Future<SetOrderModel>? _futureSetOrder;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_futureSetOrder == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(10, 50, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: bookPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "Select Delivery Day & Time",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(onTap: () {}, child: Container()),
                ],
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Image(
                          image: AssetImage('assets/images/clock.png'),
                          height: 200,
                        ),
                      ),
                    ),
                    Container(
                      width: 323,
                      // height: 405,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(
                              0,
                              2,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Set your delivery day and time',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Saturday Option
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDay =
                                          'Saturday'; // Update selected day
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedDay == 'Saturday'
                                          ? Colors.red
                                          : Colors
                                              .white, // Change color if selected
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(0),
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(0),
                                      ),
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(88, 158, 158, 158),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          40, 10, 40, 10),
                                      child: Text(
                                        'Saturday',
                                        style: TextStyle(
                                          color: selectedDay == 'Saturday'
                                              ? Colors.white
                                              : Colors
                                                  .black, // Change text color based on selection
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDay =
                                          'Sunday'; // Update selected day
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedDay == 'Sunday'
                                          ? Colors.red
                                          : Colors
                                              .white, // Change color if selected
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(10),
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(10),
                                      ),
                                      border: Border.all(
                                        color:
                                            Color.fromARGB(88, 158, 158, 158),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          40, 10, 40, 10),
                                      child: Text(
                                        'Sunday',
                                        style: TextStyle(
                                          color: selectedDay == 'Sunday'
                                              ? Colors.white
                                              : Colors
                                                  .black, // Change text color based on selection
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                            child: Container(
                              width: double.infinity,
                              height: 168,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  _buildTimeSlot('10:00 am'),
                                  _buildTimeSlot('12:00 pm'),
                                  _buildTimeSlot('03:00 pm'),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0, 1),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 20, 20, 0),
                                    child: InkWell(
                                      onTap: () async {
                                        // Show the confirmation dialog
                                        bool? isConfirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                'Confirm',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Ensures the dialog size adjusts to content
                                                children: [
                                                  // Dish Image
                                                  Container(
                                                    child: Image(
                                                      image: AssetImage(
                                                          'assets/images/clock.png'),
                                                      height: 200,
                                                    ),
                                                  ),

                                                  SizedBox(
                                                      height:
                                                          16), // Space between image and text
                                                  // Confirmation text
                                                  Text(
                                                    'This is a fast Delivery within 24 hours, this will affect you order price.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                // No button
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        false); // User clicked 'No'
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors
                                                        .red, // Color of the text
                                                  ),
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // Yes button
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        true); // User clicked 'Yes'
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors
                                                        .green, // Color of the text
                                                  ),
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // If the user confirms, proceed with adding the item to the cart
                                        if (isConfirmed == true) {
                                          // Print to debug
                                          print('####### CART ######');

                                          // Get the user ID
                                          var userId = await getUserIDPref();

                                          // Construct the data to send
                                          var data = {
                                            "chef_id": widget.selected_chef,
                                            "location_id": widget.selected_chef,
                                            "day": selectedDay,
                                            "time": selectedTime,
                                            "fast_order": true
                                          };
                                          // Print the data for debugging
                                          print(data);

                                          ///_makePostRequest(data);
                                        }
                                      },
                                      child: Container(
                                        width: 344,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(0),
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: Text(
                                            'Fast Delivery',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .copyWith(
                                                  fontFamily: 'Inter',
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0, 1),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 20, 20, 20),
                                    child: InkWell(
                                      onTap: () {
                                        // Check if location is selected
                                        if (selectedTime == "") {
                                          // Show Snackbar if no location is selected
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: bookPrimary,
                                              content: Text(
                                                  "Please select time for delivery before proceeding."),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          // Continue with the action if a location is selected
                                          print(
                                              "Location selected: $selectedTime");

                                              Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ReviewOrder())); 

                          /*                 var data = {
                                            "chef_id": widget.selected_chef,
                                            "location_id":
                                                widget.client_location,
                                            "day": selectedDay,
                                            "time": selectedTime,
                                            "fast_order": true
                                          };
*/
                                       
                                         // _futureSetOrder = setOrder(data); 
                                        }
                                      },
                                      child: Container(
                                        width: 344,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF94638),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(0),
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: Text(
                                            'Review Order',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .copyWith(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<SetOrderModel> buildFutureBuilder() {
    return FutureBuilder<SetOrderModel>(
      future: _futureSetOrder,
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
                  builder: (context) => ReviewOrder(),
                ),
              );

              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  // Show the dialog
                  return SuccessDialogBox(text: "Successful");
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
                MaterialPageRoute(builder: (context) => MyCartWidget()),
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

  // This method builds the time slot widget with conditional styling
  Widget _buildTimeSlot(String time) {
    bool isSelected = selectedTime == time; // Check if this time is selected

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTime = isSelected ? '' : time; // Toggle the selection
              });
            },
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: Text(
                time,
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      fontFamily: 'Inter',
                      letterSpacing: 0.0,
                      fontSize: isSelected ? 17 : 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                      color: isSelected
                          ? Colors.red
                          : Colors
                              .black, // Change text color based on selection
                    ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Divider(
              thickness: 2,
              color: isSelected
                  ? Colors.red
                  : Color.fromARGB(150, 158, 158,
                      158), // Change color of divider based on selection
            ),
          ),
        ],
      ),
    );
  }
}
