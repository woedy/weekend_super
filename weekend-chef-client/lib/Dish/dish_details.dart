import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weekend_chef_client/Cart/my_cart.dart';
import 'package:weekend_chef_client/ClientProfile/client_profile.dart';
import 'package:weekend_chef_client/Components/generic_loading_dialogbox.dart';
import 'package:weekend_chef_client/HomePage/HomePage.dart';
import 'package:weekend_chef_client/Dish/dish_map_view.dart';
import 'package:weekend_chef_client/Dish/models/dish_detail_model.dart';
import 'package:weekend_chef_client/Orders/my_orders.dart';
import 'package:weekend_chef_client/chef/chef_details.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<DishDetailModel> get_dish_detail_data(String dish_id) async {
  var token = await getApiPref();
  var userId = await getUserIDPref();

  final response = await http.get(
    Uri.parse(
        "${hostName}api/clients/get-client-dish-details/?dish_id=$dish_id&user_id=$userId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token ' + token.toString()
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200 || response.statusCode == 201) {
    print(jsonDecode(response.body));
    final result = json.decode(response.body);

    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 401) {
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  } else {
    //throw Exception('Failed to load data');
    print(jsonDecode(response.body));
    return DishDetailModel.fromJson(jsonDecode(response.body));
  }
}

class DishDetailsWidget extends StatefulWidget {
  final dish_id;
  const DishDetailsWidget({super.key, required this.dish_id});

  @override
  State<DishDetailsWidget> createState() => _DishDetailsWidgetState();
}

class _DishDetailsWidgetState extends State<DishDetailsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<DishDetailModel>? _futureDishDetail;
  // Chef Radius
  double _radius = 5.0;
  TabController? _tabController;

  //Cart data
  List<Custom> customData = [];
  int _quantity = 1; // Initialize the quantity

  // The variable to keep track of the selected size
  String selectedSize = '';
  late String selectedPrice; // Track the selected price#

  double totalPrice = 0.0;
  String selectedValue = "";

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _futureDishDetail = get_dish_detail_data(widget.dish_id);

    selectedSize = ''; // Initialize selectedSize as empty
    selectedPrice = ''; // Initialize selectedPrice as empty
  }

  // Method to increment the radius value
  void _incrementRadius() {
    setState(() {
      _radius += 5.0; // Increase by 5 (or modify this value as needed)
    });
  }

  // Method to decrement the radius value
  void _decrementRadius() {
    setState(() {
      if (_radius > 0) {
        _radius -= 5.0; // Decrease by 5 (or modify this value as needed)
      }
    });
  }

  // Show a success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Item added to the cart successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Make a POST request
  Future<void> _makePostRequest(data) async {
    var requestBody = {
      "dish_id": data['dish_id'],
      "user_id": data['user_id'],
      "quantity": data['quantity'],
      "package": data['package'],
      "package_price": data['package_price'],
      "value": data['value'],
      "is_custom": data['is_custom'],
      "customizations": data['customizations'],
    };

    var token = await getApiPref();

    // Show loading dialog before making the request
    LoadingDialogBox(
      text: 'Please wait...',
    );

    try {
      // Make the POST request

      final response = await http.post(
        Uri.parse("${hostName}api/orders/add-cart-item/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Token ' + token.toString()
        },
        body: jsonEncode(requestBody),
      );

      // Hide the loading dialog once the request is completed
      Navigator.of(context).pop(); // Close the loading dialog

      // Check the response
      if (response.statusCode == 200) {
        // Success
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePageWidget()));
        _showSuccessDialog();
      } else {
        // Server error or invalid data
        print(response.body);
        _showErrorDialog(
            'Failed to add item to the cart. Please try again later.');
      }
    } catch (e) {
      // Network error
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(
          'An error occurred. Please check your internet connection and try again.');
    }
  }

  Future<void> _makePostRequest2(data, dish_id) async {
    var requestBody = {
      "dish_id": data['dish_id'],
      "user_id": data['user_id'],
      "quantity": data['quantity'],
      "package": data['package'],
      "package_price": data['package_price'],
      "value": data['value'],
      "is_custom": data['is_custom'],
      "customizations": data['customizations'],
    };

    var token = await getApiPref();

    // Show loading dialog before making the request
    LoadingDialogBox(
      text: 'Please wait...',
    );

    try {
      // Make the POST request

      final response = await http.post(
        Uri.parse("${hostName}api/orders/add-cart-item/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Token ' + token.toString()
        },
        body: jsonEncode(requestBody),
      );

      // Hide the loading dialog once the request is completed
      Navigator.of(context).pop(); // Close the loading dialog

      // Check the response
      if (response.statusCode == 200) {
        // Success
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DishDetailsWidget(dish_id: dish_id)));
        _showSuccessDialog();
      } else {
        // Server error or invalid data
        print(response.body);
        _showErrorDialog(
            'Failed to add item to the cart. Please try again later.');
      }
    } catch (e) {
      // Network error
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(
          'An error occurred. Please check your internet connection and try again.');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_futureDishDetail == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: Container(),
    );
  }

  FutureBuilder<DishDetailModel> buildFutureBuilder() {
    return FutureBuilder<DishDetailModel>(
        future: _futureDishDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingDialogBox(
              text: 'Please Wait..',
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data!;

            var dishData = data.data!.dish!;

            var ingredients = data.data!.dish!.ingredients;
            var relatedFood = data.data!.relatedFoods;
            customData = data.data!.custom!;

            // Set the default selected size and price
            if (selectedSize.isEmpty) {
              selectedSize = 'Small';
              selectedPrice =
                  dishData.smallPrice!.toString(); // Set default price
              totalPrice =
                  (double.parse(dishData.smallPrice!.toString()) * _quantity);
              selectedValue = dishData.smallValue!.toString();
            }

            if (data.message == "Successful") {
              return detailsDataWidget(
                  context, dishData, relatedFood, ingredients);
            } else {
              return const LoadingDialogBox(
                text: 'Please Wait.!!!.',
              );
            }
          }

          return const LoadingDialogBox(
            text: 'Please Wait.!!!.',
          );
        });
  }

  GestureDetector detailsDataWidget(BuildContext context, Dish? dishData,
      List<RelatedFoods>? relatedFood, List<Ingredients>? ingredients) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                hostNameMedia + dishData!.coverPhoto!.toString(),
                width: double.infinity,
                height: 357,
                fit: BoxFit.cover,
              ),
            ),

            // Header Row (Back Button, Title, Search)
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(10, 45, 10, 5),
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
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 25,
                          color: Colors.white,
                        ),
                      )),
                  Text(
                    "Details",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Input Section

            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 300, 0, 0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 5),
                                  child: Text(
                                    dishData!.parentCategoryNames![0]
                                            .toString() +
                                        ' > ' +
                                        dishData!.categoryName!.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF757575),
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dishData!.name!.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 24,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedValue.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Ghc ',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF209220),
                                          fontSize: 10,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Text(
                                        totalPrice.toString(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF209220),
                                          fontSize: 20,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        1, 0, 0, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 10, 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_quantity > 1) {
                                                  _quantity--; // Decrement the quantity
                                                }

                                                totalPrice = double.parse(
                                                        selectedPrice) *
                                                    _quantity;
                                              });
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF94638),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                ),
                                              ),
                                              child: Align(
                                                alignment:
                                                    AlignmentDirectional(0, 0),
                                                child: Text(
                                                  '-',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$_quantity',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 20,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _quantity++; // Increment the quantity

                                                totalPrice = double.parse(
                                                        selectedPrice) *
                                                    _quantity;
                                              });
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF94638),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                ),
                                              ),
                                              child: Align(
                                                alignment:
                                                    AlignmentDirectional(0, 0),
                                                child: Text(
                                                  '+',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _showCustomBottomModal(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF00BD1C),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20, 5, 20, 5),
                                            child: Text(
                                              'Customize',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.white,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
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
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment(0, 0),
                              child: TabBar(
                                labelColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                unselectedLabelColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                                labelStyle: TextStyle(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 13,
                                  letterSpacing: 0.0,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 13,
                                  letterSpacing: 0.0,
                                ),
                                indicatorColor: Color(0xFFF94638),
                                indicatorWeight: 3,
                                tabs: [
                                  Tab(
                                    text: 'Info',
                                  ),
                                  Tab(
                                    text: 'Ingredients',
                                  ),
                                ],
                                controller: _tabController,
                                onTap: (i) async {
                                  [() async {}, () async {}][i]();
                                },
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          width: double.infinity,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(15, 15, 0, 15),
                                                child: Text(
                                                  dishData!.description!
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 1, 0, 0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 78,
                                                  decoration: BoxDecoration(
                                                      //  color: Theme.of(context).backgroundColor,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                20, 0, 20, 0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween, // Ensure the items are spaced out evenly
                                                      children: [
                                                        // Small Size Container wrapped in Expanded
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedSize =
                                                                    'Small';
                                                                selectedPrice = dishData
                                                                    .smallPrice!
                                                                    .toString();

                                                                selectedValue = dishData
                                                                    .smallValue!
                                                                    .toString();
                                                                totalPrice =
                                                                    double.parse(
                                                                            selectedPrice) *
                                                                        _quantity;
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: selectedSize ==
                                                                        'Small'
                                                                    ? Color(
                                                                        0xFFFB8030)
                                                                    : Color(
                                                                        0xFFC3C3C3),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          0),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            5,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Small',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Small'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Ghc ' +
                                                                          dishData!
                                                                              .smallPrice!
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Small'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        // Medium Size Container wrapped in Expanded
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedSize =
                                                                    'Medium';
                                                                selectedPrice = dishData
                                                                    .mediumPrice!
                                                                    .toString();
                                                                selectedValue = dishData
                                                                    .mediumValue!
                                                                    .toString();
                                                                totalPrice =
                                                                    double.parse(
                                                                            selectedPrice) *
                                                                        _quantity;
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: selectedSize ==
                                                                        'Medium'
                                                                    ? Color(
                                                                        0xFFFB8030)
                                                                    : Color(
                                                                        0xFFC3C3C3),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          0),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            5,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Medium',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Medium'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Ghc ' +
                                                                          dishData!
                                                                              .mediumPrice!
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Medium'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        // Large Size Container wrapped in Expanded
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedSize =
                                                                    'Large';

                                                                selectedPrice = dishData
                                                                    .largePrice!
                                                                    .toString();
                                                                selectedValue = dishData
                                                                    .largeValue!
                                                                    .toString();
                                                                totalPrice =
                                                                    double.parse(
                                                                            selectedPrice) *
                                                                        _quantity;
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: selectedSize ==
                                                                        'Large'
                                                                    ? Color(
                                                                        0xFFFB8030)
                                                                    : Color(
                                                                        0xFFC3C3C3),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          5),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          5),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            5,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Large',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Large'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            5),
                                                                    child: Text(
                                                                      'Ghc ' +
                                                                          dishData!
                                                                              .largePrice!
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: selectedSize ==
                                                                                'Large'
                                                                            ? Colors.white
                                                                            : Color(0xFF171717),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 30, 0, 0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                20, 0, 20, 0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                            child: InkWell(
                                                          onTap: () async {
                                                            // Show the confirmation dialog
                                                            bool? isConfirmed =
                                                                await showDialog<
                                                                    bool>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    'Confirm',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min, // Ensures the dialog size adjusts to content
                                                                    children: [
                                                                      // Dish Image
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10), // Rounded corners
                                                                        child: Image
                                                                            .network(
                                                                          hostNameMedia +
                                                                              dishData!.coverPhoto!.toString(),
                                                                          width:
                                                                              64,
                                                                          height:
                                                                              64,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              16), // Space between image and text
                                                                      // Confirmation text
                                                                      Text(
                                                                        'Are you sure you want to add this item to the cart?',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: <Widget>[
                                                                    // No button
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(false); // User clicked 'No'
                                                                      },
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        foregroundColor:
                                                                            Colors.red, // Color of the text
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'No',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Yes button
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(true); // User clicked 'Yes'
                                                                      },
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        foregroundColor:
                                                                            Colors.green, // Color of the text
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Yes',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
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
                                                            if (isConfirmed ==
                                                                true) {
                                                              // Print to debug
                                                              print(
                                                                  '####### CART ######');

                                                              // Get the user ID
                                                              var userId =
                                                                  await getUserIDPref();

                                                              // Check if any customizations have quantities greater than 0
                                                              var is_custom =
                                                                  customData.any(
                                                                      (item) =>
                                                                          item.quantity >
                                                                          0);

                                                              // Construct the data to send
                                                              var data = {
                                                                "dish_id": dishData!
                                                                    .dishId
                                                                    .toString(),
                                                                "user_id":
                                                                    userId,
                                                                "quantity":
                                                                    _quantity,
                                                                "package":
                                                                    selectedSize,
                                                                "package_price":
                                                                    selectedPrice,
                                                                "value":
                                                                    selectedValue,
                                                                "is_custom":
                                                                    is_custom,
                                                                "customizations":
                                                                    customData
                                                                        .map((e) =>
                                                                            {
                                                                              "custom_option_id": e.customOptionId,
                                                                              "quantity": e.quantity
                                                                            })
                                                                        .toList()
                                                              };

                                                              // Print the data for debugging
                                                              print(data);

                                                              _makePostRequest(
                                                                  data);
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF94638),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0),
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0, 0),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20,
                                                                            5,
                                                                            20,
                                                                            5),
                                                                child: Text(
                                                                  'Add to Cart',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                        Expanded(
                                                          child: Container(
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5),
                                                              ),
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFFAEAEAE),
                                                              ),
                                                            ),
                                                            child: InkWell(
                                                              onTap: () {
                                                                _showRelatedBottomModal(
                                                                    context,
                                                                    relatedFood,
                                                                    dishData);
                                                              },
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0, 0),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          5,
                                                                          20,
                                                                          5),
                                                                  child: Text(
                                                                    'Add & View Related',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: Color(
                                                                          0xFF626262),
                                                                      fontSize:
                                                                          13,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 130,
                                          decoration: BoxDecoration(),
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: ingredients!.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  width: 120,
                                                  decoration: BoxDecoration(),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                5, 10, 5, 0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      0, 0, 5),
                                                          child: Container(
                                                            width: 64,
                                                            height: 64,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              image:
                                                                  DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: Image.network(hostNameMedia +
                                                                        ingredients![index]!
                                                                            .photo!
                                                                            .toString())
                                                                    .image,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          ingredients[index]
                                                              .name!
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              letterSpacing:
                                                                  0.0,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(),
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
            ),

            customNavBar(context)
          ],
        ),
      ),
    );
  }

  void _showCustomBottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (BuildContext context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Title Row
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Customize food',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Extra Adons',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),

                      // List of items (customData)
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount:
                              customData.length, // Ensure customData is updated
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    hostNameMedia +
                                                        customData[index]
                                                            .photo!)),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customData[index].name!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Row(
                                              children: [
                                                Text('Ghc ',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                Text(customData[index].price!,
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Decrement button for custom data
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (customData[index].quantity >
                                                  0) {
                                                customData[index]
                                                    .quantity--; // Decrease quantity
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '-',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0),
                                          child: Text(
                                            '${customData[index].quantity}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // Increment button for custom data
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              customData[index]
                                                  .quantity++; // Increase quantity
                                            });
                                          },
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF94638),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                ),
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
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRelatedBottomModal(
      BuildContext context, relatedFoodData, dishData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //backgroundColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3, // Initial size of the modal
          minChildSize: 0.2, // Minimum height of the modal
          maxChildSize: 0.8, // Maximum height of the modal
          builder: (BuildContext context, scrollController) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Best With',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: relatedFoodData.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            // Show the confirmation dialog
                            bool? isConfirmed = await showDialog<bool>(
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                        child: Image.network(
                                          hostNameMedia +
                                              dishData!.coverPhoto!.toString(),
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              16), // Space between image and text
                                      // Confirmation text
                                      Text(
                                        'Are you sure you want to add this item to the cart?',
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
                                        Navigator.of(context)
                                            .pop(false); // User clicked 'No'
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.red, // Color of the text
                                      ),
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Yes button
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // User clicked 'Yes'
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.green, // Color of the text
                                      ),
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
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

                              // Check if any customizations have quantities greater than 0
                              var is_custom =
                                  customData.any((item) => item.quantity > 0);

                              // Construct the data to send
                              var data = {
                                "dish_id": dishData!.dishId.toString(),
                                "user_id": userId,
                                "quantity": _quantity,
                                "package": selectedSize,
                                "package_price": selectedPrice,
                                "value": selectedValue,
                                "is_custom": is_custom,
                                "customizations": customData
                                    .map((e) => {
                                          "custom_option_id": e.customOptionId,
                                          "quantity": e.quantity
                                        })
                                    .toList()
                              };

                              // Print the data for debugging
                              print(data);

                              _makePostRequest2(data, relatedFoodData[index].dishId.toString());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    hostNameMedia +
                                                        relatedFoodData[index]
                                                            .coverPhoto
                                                            .toString()))),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              relatedFoodData[index]
                                                  .name
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    relatedFoodData[index]
                                                        .description
                                                        .toString(),
                                                    overflow: TextOverflow
                                                        .ellipsis, // This adds '...' at the end if text overflows
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Positioned customNavBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 13),
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bookPrimaryDark, bookPrimary],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          /*           boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ], */
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors
                    .transparent, // Use transparent to let the gradient show
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(0.2), // Slightly transparent white background
                  ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        print('Home tapped');
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/icons/home.png",
                            height: 20,
                            color: Colors
                                .grey, // Change color to contrast with blue
                          ),
                          const Text('Home',
                              style: TextStyle(fontSize: 9, color: Colors.grey))
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MyOrdersWidget()),
                        );
                      },
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/icons/card.png",
                                height: 20,
                                color: Colors.white,
                              ),
                              const Text('My Orders',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white))
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Column(
                        children: [
                          Column(
                            children: [
                              Icon(Icons.explore, color: Colors.white),
                              Text('Transactions',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white))
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/icons/message.png",
                                height: 20,
                                color: Colors.white,
                              ),
                              const Text('Settings',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white))
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const ClientProfilePageWidget()),
                        );
                      },
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/icons/person.png",
                                height: 20,
                                color: Colors.white,
                              ),
                              const Text('Profile',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white))
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
}
