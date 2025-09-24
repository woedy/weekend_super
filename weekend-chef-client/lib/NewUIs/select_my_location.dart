import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/Cart/models/all_cart_items_model.dart';
import 'package:weekend_chef_client/Cart/cart_detail_edit.dart';
import 'package:weekend_chef_client/Cart/models/chefs_model.dart';
import 'package:weekend_chef_client/Cart/models/select_location_model.dart';
import 'package:weekend_chef_client/Cart/select_chef.dart';
import 'package:weekend_chef_client/chef/chef_details.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<SelectMyLocationsModel> get_all_locations(
    {int page = 1,
    Map<String, String>? filters,
    String? search_query,
    double? radius}) async {
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
      'api/orders/get-my-locations/?search=${search_query ?? ''}&user_id=$userId&page=$page$filterQuery';

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

      return SelectMyLocationsModel.fromJson(
          parsedData); // Return the parsed model
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse JSON');
    }
  } else {
    throw Exception('Failed to load data');
  }
}

class MyLocationWidget extends StatefulWidget {
  const MyLocationWidget({super.key});

  @override
  State<MyLocationWidget> createState() => _MyLocationWidgetState();
}

class _MyLocationWidgetState extends State<MyLocationWidget>
    with TickerProviderStateMixin {
  Future<SelectMyLocationsModel?>? _futureAllCarts;
  List<Locations> _allLocations = [];
  bool _isLoading = false;
  bool _isSearchVisible = false;
  int _currentPage = 1;
  int _totalPages = 1;
  double radius = 10.0; // Default radius

  Map<String, String>? _filters;
  String? _searchQuery;

  String? selectedLocationID; // This will hold the selected location's ID

  // Animation controllers for each list item
  List<AnimationController>? _controllers;

  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer; // Timer to handle debouncing

  Future<SelectMyLocationsModel?> _fetchLocations(
      {bool loadMore = false}) async {
    if (_isLoading) return Future.error('Loading in progress');

    setState(() {
      _isLoading = true;
    });

    try {
      final cartsData = await get_all_locations(
          page: loadMore ? _currentPage + 1 : 1,
          filters: _filters,
          search_query: _searchQuery,
          radius: radius);

      // Check if the response is null or has no cartItems
      if (cartsData == null ||
          cartsData.data == null ||
          cartsData.data!.locations == null) {
        print("No data found in response.");
        return Future.error('Failed to load data');
      }

      print("Cart items fetched: ${cartsData.data!.locations!.length}");

      setState(() {
        if (loadMore) {
          _allLocations.addAll(cartsData.data!.locations!);
          _currentPage++;
        } else {
          _allLocations = cartsData.data!.locations!;
          _currentPage = 1;
        }
        _isLoading = false;

        // Reinitialize animation controllers after fetching locations
        _controllers = List.generate(_allLocations.length, (index) {
          return AnimationController(
            duration: Duration(milliseconds: 500),
            vsync: this,
          )..forward();
        });
      });

      return cartsData;
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
    _fetchLocations(loadMore: false); // Call server to update with new radius
  }

  void decrementRadius() {
    setState(() {
      if (radius > 5.0) {
        radius -= 5.0; // Decrease radius by 5, but ensure it doesn't go below 5
      }
    });
    _fetchLocations(loadMore: false); // Call server to update with new radius
  }

  @override
  void initState() {
    super.initState();
    _futureAllCarts = _fetchLocations();
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
                    child: FutureBuilder<SelectMyLocationsModel?>(
                      future: _futureAllCarts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data?.data?.locations?.isEmpty == true) {
                          return Center(child: Text('No cart items available'));
                        } else {
                          final allLocations = snapshot.data!.data!.locations!;
                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!_isLoading &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                if (_currentPage < _totalPages) {
                                  _fetchLocations(loadMore: true);
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
                                        "Available Locations",
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
                                                        'Select Location',
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
                                            //height: 250,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                    width: double.infinity,
                                                    //height: 181.11,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          allLocations.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        String locationID =
                                                            allLocations[index]
                                                                .locationId
                                                                .toString(); // Assuming the location has an ID
                                                        bool isSelected =
                                                            locationID ==
                                                                selectedLocationID; // Check if this location's ID matches the selected ID

                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              // Update the selected location when tapped
                                                              selectedLocationID =
                                                                  locationID;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        15,
                                                                        10,
                                                                        15,
                                                                        0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_pin,
                                                                          color: isSelected
                                                                              ? Colors.green
                                                                              : Color(0xFF1BA300), // Change color if selected
                                                                          size:
                                                                              24,
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              15,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                allLocations[index].locationName!,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Inter',
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: isSelected ? Colors.green : Colors.black, // Change text color if selected
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                                                                child: Text(
                                                                                  allLocations[index].digitalAddress!,
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Inter',
                                                                                    fontSize: 12,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.normal,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              0,
                                                                              0,
                                                                              15,
                                                                              0),
                                                                      child:
                                                                          Icon(
                                                                        isSelected
                                                                            ? Icons.check_circle
                                                                            : Icons.circle_outlined, // Show check icon if selected
                                                                        color: isSelected
                                                                            ? Colors.green
                                                                            : Colors.grey, // Change icon color if selected
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Divider(
                                                                  thickness: 2,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          62,
                                                                          158,
                                                                          158,
                                                                          158),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            // Select My Current Location Button
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 25, 0, 20),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0, 1),
                                                    child: InkWell(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 344,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0, 0),
                                                          child: Text(
                                                            'Use My Current location',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color:
                                                                  Colors.black,
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

                                            // Select Chef Button
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 25, 0, 20),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0, 1),
                                                    child: InkWell(
                                                      onTap: () {
                                                        // Check if location is selected
                                                        if (selectedLocationID ==
                                                            null) {
                                                          // Show Snackbar if no location is selected
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                                  bookPrimary,
                                                              content: Text(
                                                                  "Please select a location before proceeding."),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        } else {
                                                          // Continue with the action if a location is selected
                                                          print(
                                                              "Location selected: $selectedLocationID");

                                                          Navigator.of(context).push(MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  SelectChefWidget(
                                                                      client_location_id:
                                                                          selectedLocationID)));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 344,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFF94638),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0, 0),
                                                          child: Text(
                                                            'Select Chef',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color:
                                                                  Colors.white,
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
  Padding searchInputSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController, // Controller to handle the text input
        decoration: InputDecoration(
          labelText: 'Search',
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          suffixIcon: _searchQuery?.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _searchQuery = ''; // Clear the search query
                      _searchController.clear(); // Clear the text field
                    });
                    _applyFilters(); // You can call _applyFilters to reset or refresh data
                  },
                )
              : null, // Only show the clear icon if there is text in the field
        ),
        style: TextStyle(color: Colors.black),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });

          // Cancel the previous timer if the user types before the delay ends
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel();
          }

          // Start a new timer that waits 1 second after the last keystroke
          _debounceTimer = Timer(Duration(seconds: 1), () {
            _applyFilters(); // Apply filters after the user stops typing for 1 second
          });
        },
      ),
    );
  }

  // Apply filters
  void _applyFilters() {
    setState(() {
      _futureAllCarts = _fetchLocations();
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
