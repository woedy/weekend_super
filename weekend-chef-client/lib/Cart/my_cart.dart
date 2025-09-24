import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/Cart/models/all_cart_items_model.dart';
import 'package:weekend_chef_client/Cart/cart_detail_edit.dart';
import 'package:weekend_chef_client/Cart/select_chef.dart';
import 'package:weekend_chef_client/NewUIs/select_my_location.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<AllCartItemsModel> get_all_cartItems(
    {int page = 1, Map<String, String>? filters, String? search_query}) async {
  var token = await getApiPref();

  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/orders/get-all-cart-items/?search=${search_query ?? ''}&page=$page$filterQuery';

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

      return AllCartItemsModel.fromJson(parsedData); // Return the parsed model
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse JSON');
    }
  } else {
    throw Exception('Failed to load data');
  }
}

class MyCartWidget extends StatefulWidget {
  const MyCartWidget({super.key});

  @override
  State<MyCartWidget> createState() => _MyCartWidgetState();
}

class _MyCartWidgetState extends State<MyCartWidget>
    with TickerProviderStateMixin {
  Future<AllCartItemsModel?>? _futureAllCarts;
  List<CartItems> _allCartItems = [];
  bool _isLoading = false;
  bool _isSearchVisible = false;
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, String>? _filters;
  String? _searchQuery;

  // Animation controllers for each list item
  List<AnimationController>? _controllers;

  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer; // Timer to handle debouncing

  Future<AllCartItemsModel?> _fetchCartItems({bool loadMore = false}) async {
    if (_isLoading) return Future.error('Loading in progress');

    setState(() {
      _isLoading = true;
    });

    try {
      final cartsData = await get_all_cartItems(
        page: loadMore ? _currentPage + 1 : 1,
        filters: _filters,
        search_query: _searchQuery,
      );

      // Check if the response is null or has no cartItems
      if (cartsData == null ||
          cartsData.data == null ||
          cartsData.data!.cartItems == null) {
        print("No data found in response.");
        return Future.error('Failed to load data');
      }

      print("Cart items fetched: ${cartsData.data!.cartItems!.length}");

      setState(() {
        if (loadMore) {
          _allCartItems.addAll(cartsData.data!.cartItems!);
          _currentPage++;
        } else {
          _allCartItems = cartsData.data!.cartItems!;
          _currentPage = 1;
        }
        _totalPages = cartsData.data!.pagination!.totalPages!;
        _isLoading = false;

        // Reinitialize animation controllers after fetching cartItems
        _controllers = List.generate(_allCartItems.length, (index) {
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

  Future<bool> deleteCartItem(int cartItemId) async {
    var token = await getApiPref();

    final String url = hostName + 'api/orders/delete-cart-item/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'item_id': cartItemId,
        }),
      );

      if (response.statusCode == 200) {
        // Return true if the item was deleted successfully
        return true;
      } else {
        // Handle error if deletion fails
        throw Exception('Failed to delete cart item');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAllCarts = _fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Row (Back Button, Title, Search)
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 5),
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
                        "My Cart",
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
                            _searchQuery = ''; // Clear the search query
                            _searchController.clear(); // Clear the text field
                          });
                          _applyFilters(); // Call _applyFilters to reset or refresh data
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _isSearchVisible ? Icons.search_off : Icons.search,
                            size: 20,
                            color:
                                _isSearchVisible ? bookPrimary : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Input Section
                _isSearchVisible
                    ? AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(5.0),
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: _isSearchVisible ? 1 : 0,
                          child: searchInputSection(),
                        ),
                      )
                    : Container(),

                // Cart Item List
                Expanded(
                  child: Container(
                    child: FutureBuilder<AllCartItemsModel?>(
                      future: _futureAllCarts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data?.data?.cartItems?.isEmpty == true) {
                          return Center(child: Text('No cart items available'));
                        } else {
                          final allCartItems = snapshot.data!.data!.cartItems!;
                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!_isLoading &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                if (_currentPage < _totalPages) {
                                  _fetchCartItems(loadMore: true);
                                }
                                return true;
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount:
                                  allCartItems.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == allCartItems.length) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                return listDataWidget(
                                    context, allCartItems, index);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 1),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const MyLocationWidget()));
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
                            'Select your location',
                            style: TextStyle(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List data widget with animations
  Padding listDataWidget(
      BuildContext context, List<CartItems> allCartItems, int index) {
    // Ensure the controllers list is not null and has enough controllers
    if (_controllers == null || _controllers!.length <= index) {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
        child: Text('Controller not available'),
      );
    }
    final controller = _controllers![index];
    final slideAnimation = Tween<Offset>(
            begin: Offset(0.0, 0.2), end: Offset(0.0, 0.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, 3, 10, 0),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: 1.0,
        child: SlideTransition(
          position: slideAnimation,
          child: listDataContentWidget(context, allCartItems, index),
        ),
      ),
    );
  }

  Container listDataContentWidget(
      BuildContext context, List<CartItems> allCartItems, int index) {
    return Container(
      width: 100,
      height: 200,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartDetailEditWidget(
                          cart_item_id: allCartItems[index].id)));
            },
            child: Align(
              alignment: AlignmentDirectional(0, 1),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                child: Container(
                  width: double.infinity,
                  height: 154,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF800A00), Color(0xFFF94638)],
                      stops: [0, 1],
                      begin: AlignmentDirectional(-1, 0),
                      end: AlignmentDirectional(1, 0),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 10, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    allCartItems[index].dishName!.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontSize: 20,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 5, 0, 0),
                                    child: Text(
                                      allCartItems[index]
                                              .parentCategoryNames![0] +
                                          ' > ' +
                                          allCartItems[index]
                                              .category!
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
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
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 10, 0, 0),
                                    child: Text(
                                      'Ghc ' +
                                          allCartItems[index]
                                              .itemTotalPrice!
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontSize: 20,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                child: Column(
                                  children: [
                                    if (allCartItems[index].isCustom!) ...[
                                      Container(
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
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(1.14, 0.68),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.network(hostNameMedia +
                          allCartItems[index].dishCoverPhoto!.toString())
                      .image,
                ),
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
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.91, -0.93),
            child: InkWell(
              onTap: () async {
                // Show a loading indicator while deleting
                setState(() {
                  _isLoading = true;
                });

                // Call the delete method and update the UI
                bool success = await deleteCartItem(allCartItems[index].id!);

                setState(() {
                  _isLoading = false;
                });

                if (success) {
                  // Remove the deleted item from the list
                  setState(() {
                    allCartItems.removeAt(index);
                  });
                } else {
                  // Show error message if deletion fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete cart item')),
                  );
                }
              },
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Icon(
                    Icons.close_sharp,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
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
      _futureAllCarts = _fetchCartItems();
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
