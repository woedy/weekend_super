import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/Cart/delivery_date.dart';
import 'package:weekend_chef_client/Cart/models/all_cart_items_model.dart';
import 'package:weekend_chef_client/Cart/cart_detail_edit.dart';
import 'package:weekend_chef_client/Cart/models/chefs_model.dart';
import 'package:weekend_chef_client/Cart/select_chef.dart';
import 'package:weekend_chef_client/chef/chef_details.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<AvailableChefsModel> get_all_nearbyChefs(
    {int page = 1,
    Map<String, String>? filters,
    String? search_query,
    double? radius,
    String? client_location_id}) async {
  var token = await getApiPref();
  var userId = await getUserIDPref();

  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/orders/get-closest-chefs/?search=${search_query ?? ''}&user_id=$userId&radius=$radius&location_id=$client_location_id&page=$page$filterQuery';

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    },
  );

  if (response.statusCode == 200) {
    print('########################');
    print(response.body); // Print the raw response for debugging

    try {
      final parsedData = jsonDecode(response.body);
      print('Parsed data: $parsedData'); // Print the parsed data

      return AvailableChefsModel.fromJson(
          parsedData); // Return the parsed model
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse JSON');
    }
  } else {
    throw Exception('Failed to load data');
  }
}

class SelectChefWidget extends StatefulWidget {
  final client_location_id;

  const SelectChefWidget({super.key, required this.client_location_id});

  @override
  State<SelectChefWidget> createState() => _SelectChefWidgetState();
}

class _SelectChefWidgetState extends State<SelectChefWidget>
    with TickerProviderStateMixin {
  Future<AvailableChefsModel?>? _futureAllChefs;
  List<NearbyChefs> _allNearbyChefs = [];
  bool _isLoading = false;
  bool _isSearchVisible = false;
  int _currentPage = 1;
  int _totalPages = 1;
  double radius = 10.0; // Default radius

  Map<String, String>? _filters;
  String? _searchQuery;

  String? selectedChefID; // This will hold the selected chef's ID

  // Animation controllers for each list item
  List<AnimationController>? _controllers;

  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer; // Timer to handle debouncing

  Future<AvailableChefsModel?> _fetchNearbyChefs(
      {bool loadMore = false}) async {
    if (_isLoading) return Future.error('Loading in progress');

    setState(() {
      _isLoading = true;
    });

    try {
      final chefsData = await get_all_nearbyChefs(
        page: loadMore ? _currentPage + 1 : 1,
        filters: _filters,
        search_query: _searchQuery,
        radius: radius,
        client_location_id: widget.client_location_id.toString(),
      );

      // Check if the response is null or has no chefItems
      if (chefsData == null ||
          chefsData.data == null ||
          chefsData.data!.nearbyChefs == null) {
        print("No data found in response.");
        return Future.error('Failed to load data');
      }

      print("Chef items fetched: ${chefsData.data!.nearbyChefs!.length}");

      setState(() {
        if (loadMore) {
          _allNearbyChefs.addAll(chefsData.data!.nearbyChefs!);
          _currentPage++;
        } else {
          _allNearbyChefs = chefsData.data!.nearbyChefs!;
          _currentPage = 1;
        }
        _isLoading = false;
      });

      return chefsData;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('Error: $e');
      return Future.error('Failed to load data222');
    }
  }

  void incrementRadius() {
    setState(() {
      radius += 5.0; // Increase radius by 5
    });
    _applyFilters(); // Re-fetch data after applying the new filter
  }

  void decrementRadius() {
    setState(() {
      if (radius > 5.0) {
        radius -= 5.0; // Decrease radius by 5, but ensure it doesn't go below 5
      }
    });
    _applyFilters(); // Re-fetch data after applying the new filter
  }

  @override
  void initState() {
    super.initState();
    _futureAllChefs = _fetchNearbyChefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    child: FutureBuilder<AvailableChefsModel?>(
                      future: _futureAllChefs,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data?.data?.nearbyChefs?.isEmpty == true) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/maps.jpg'),
                                        fit: BoxFit.cover)),
                              ),
                              Container(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10, 10, 10, 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Available Chefs",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isSearchVisible =
                                              !_isSearchVisible; // Toggle search visibility
                                          _searchQuery =
                                              ''; // Clear the search query
                                          _searchController
                                              .clear(); // Clear the text field
                                        });
                                        _applyFilters(); // Call _applyFilters to reset or refresh data
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          _isSearchVisible
                                              ? Icons.search_off
                                              : Icons.search,
                                          size: 20,
                                          color: _isSearchVisible
                                              ? bookPrimary
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 400, 0, 0),
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
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20, 20, 20, 0),
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 0, 0, 10),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Select Chef',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 20,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      "No chef available in your area. increase redius."),
                                                )),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 15, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(0, 0,
                                                                    10, 0),
                                                        child: InkWell(
                                                          onTap:
                                                              decrementRadius, // Call decrement function when the '-' button is pressed
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF94638),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              5)),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0, 0),
                                                              child: Text(
                                                                '-',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$radius', // Display the updated radius
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 20,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(10, 0,
                                                                    10, 0),
                                                        child: InkWell(
                                                          onTap:
                                                              incrementRadius, // Call increment function when the '+' button is pressed
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF94638),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              5)),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0, 0),
                                                              child: Text(
                                                                '+',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 3, 0, 0),
                                                  child: Text(
                                                    'Radius',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0.0,
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
                          );
                        } else {
                          final allNearbyChefs =
                              snapshot.data!.data!.nearbyChefs!;
                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!_isLoading &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                if (_currentPage < _totalPages) {
                                  _fetchNearbyChefs(loadMore: true);
                                }
                                return true;
                              }
                              return false;
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/maps.jpg'),
                                          fit: BoxFit.cover)),
                                ),
                                Container(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 10, 10, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Available Chefs",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _isSearchVisible =
                                                !_isSearchVisible; // Toggle search visibility
                                            _searchQuery =
                                                ''; // Clear the search query
                                            _searchController
                                                .clear(); // Clear the text field
                                          });
                                          _applyFilters(); // Call _applyFilters to reset or refresh data
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            _isSearchVisible
                                                ? Icons.search_off
                                                : Icons.search,
                                            size: 20,
                                            color: _isSearchVisible
                                                ? bookPrimary
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 400, 0, 0),
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
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20, 20, 20, 0),
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 0, 10),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Select Available Chef',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 20,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
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
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                    width: double.infinity,
                                                    height: 181.11,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          allNearbyChefs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        String chefID =
                                                            allNearbyChefs[
                                                                    index]
                                                                .chefId!
                                                                .toString(); // Assume the chefs have an ID
                                                        bool isSelected = chefID ==
                                                            selectedChefID; // Check if this chef's ID matches the selected ID

                                                        return Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(5,
                                                                      5, 5, 5),
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                // Toggle selection based on whether the chef is already selected
                                                                selectedChefID =
                                                                    isSelected
                                                                        ? null
                                                                        : chefID;
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 130,
                                                              height: 100,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isSelected
                                                                    ? Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.2)
                                                                    : Colors
                                                                        .white, // Highlight color
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12), // Optional, for rounded corners
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0,
                                                                            1),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          115,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color(
                                                                            0xFFF94638),
                                                                        borderRadius:
                                                                            BorderRadius.circular(14),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            10),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 5),
                                                                              child: Text(
                                                                                allNearbyChefs[index].chefName!.toString(),
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Inter',
                                                                                  color: Colors.white,
                                                                                  fontSize: 13,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                                                                              child: Text(
                                                                                allNearbyChefs[index].distance!.toString() + " km",
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Inter',
                                                                                  color: Colors.white,
                                                                                  fontSize: 9,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0,
                                                                            -1),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => const ChefDetailsWidget()));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            95,
                                                                        height:
                                                                            95,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          image:
                                                                              DecorationImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            image:
                                                                                NetworkImage(hostNameMedia + allNearbyChefs[index].chefPhoto!.toString()),
                                                                          ),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 15, 0, 0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        10,
                                                                        0),
                                                            child: InkWell(
                                                              onTap:
                                                                  decrementRadius, // Call decrement function when the '-' button is pressed
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xFFF94638),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0, 0),
                                                                  child: Text(
                                                                    '-',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            '$radius', // Display the updated radius
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 20,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                            child: InkWell(
                                                              onTap:
                                                                  incrementRadius, // Call increment function when the '+' button is pressed
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xFFF94638),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0, 0),
                                                                  child: Text(
                                                                    '+',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
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
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 3, 0, 0),
                                                      child: Text(
                                                        'Radius',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 25, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0, 1),
                                                        child: InkWell(
                                                          onTap: () {
                                                            // Check if location is selected
                                                            if (selectedChefID ==
                                                                null) {
                                                              // Show Snackbar if no location is selected
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      bookPrimary,
                                                                  content: Text(
                                                                      "Please select a chef before proceeding."),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            } else {
                                                              // Continue with the action if a location is selected
                                                              print(
                                                                  "Location selected: $selectedChefID");

                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          SelectDayTimeWidget(
                                                                            selected_chef: selectedChefID,
                                                                            client_location: widget.client_location_id


                                                                          )));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 344,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF94638),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                              ),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0, 0),
                                                              child: Text(
                                                                'Select Delivery Time',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Search input section with debounce and clear icon

  // Apply filters
  void _applyFilters() {
    setState(() {
      _futureAllChefs = _fetchNearbyChefs();
    });
  }

  @override
  void dispose() {
    // Cancel the debounce timer when widget is disposed
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
