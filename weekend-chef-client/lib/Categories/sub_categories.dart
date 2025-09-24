import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:weekend_chef_client/ClientProfile/client_profile.dart';
import 'package:weekend_chef_client/Dish/dishes.dart';
import 'package:weekend_chef_client/Categories/models/categories_model.dart';
import 'package:weekend_chef_client/Categories/sub_categories.dart';
import 'package:weekend_chef_client/Orders/my_orders.dart';
import 'package:weekend_chef_client/constants.dart';
import 'package:weekend_chef_client/utils/custom_ui.dart';

Future<CategoriesModel> get_all_subCategories(
    {int page = 1, Map<String, String>? filters, String? search_query, String? category_id}) async {
  var token = await getApiPref();

  // Construct the query parameters from the filters map
  String filterQuery = '';
  if (filters != null) {
    filters.forEach((key, value) {
      filterQuery += '&$key=$value';
    });
  }

  final String url = hostName +
      'api/clients/get-all-client-food-sub-categories/?search=${search_query ?? ''}&page=$page$filterQuery&category_id=${category_id ?? ''}';

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Token $token', //+ token.toString()
      //'Authorization': 'Token '  + token.toString()
    },
  );

  if (response.statusCode == 200) {
    print(response.body);
    return CategoriesModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data');
  }
}

class SubCategoriesWidget extends StatefulWidget {
  final category_id;
  final category_name;

  const SubCategoriesWidget(
      {super.key, required this.category_id, required this.category_name});

  @override
  State<SubCategoriesWidget> createState() => _SubCategoriesWidgetState();
}

class _SubCategoriesWidgetState extends State<SubCategoriesWidget>
    with TickerProviderStateMixin {
  Future<CategoriesModel?>? _futureAllCategories;
  List<FoodCategories> _allCategories = [];
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

  Future<CategoriesModel?> _fetchCategories({bool loadMore = false}) async {
    if (_isLoading) return Future.error('Loading in progress');

    setState(() {
      _isLoading = true;
    });

    try {
      final subCategoriesData = await get_all_subCategories(
        page: loadMore ? _currentPage + 1 : 1,
        filters: _filters,
        search_query: _searchQuery,
        category_id: widget.category_id.toString()

      );

      setState(() {
        if (loadMore) {
          _allCategories.addAll(subCategoriesData.data!.foodCategories!);
          _currentPage++;
        } else {
          _allCategories = subCategoriesData.data!.foodCategories!;
          _currentPage = 1;
        }
        _totalPages = subCategoriesData.data!.pagination!.totalPages!;
        _isLoading = false;

        // Reinitialize the animation controllers after fetching the subCategories
        _controllers = List.generate(_allCategories.length, (index) {
          return AnimationController(
            duration: Duration(milliseconds: 500),
            vsync: this,
          )..forward();
        });
      });

      if (_allCategories.isEmpty) {
        return null;
      }

      return subCategoriesData;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      return Future.error('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAllCategories = _fetchCategories();
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
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: Colors.white,
                            ),
                          )),
                      Text(
                        widget.category_name.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSearchVisible =
                                !_isSearchVisible; // Toggle search visibility
                            _searchQuery = ''; // Clear the search query
                            _searchController.clear(); // Clear the text field
                          });
                          _applyFilters(); // You can call _applyFilters to reset or refresh data
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

                // Category List
                Expanded(
                  child: Container(
                    child: FutureBuilder<CategoriesModel?>(
                      future: _futureAllCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            _allCategories.isEmpty) {
                          return Center(child: Text('No categories available'));
                        } else {
                          final allCategories =
                              snapshot.data!.data!.foodCategories!;
                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!_isLoading &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                if (_currentPage < _totalPages) {
                                  _fetchCategories(loadMore: true);
                                }
                                return true;
                              }
                              return false;
                            },
                            child: ListView.builder(
                              //padding: EdgeInsets.zero, // Remove any extra padding
                              padding: EdgeInsets.only(
                                  bottom:
                                      kBottomNavigationBarHeight), // Add padding at the bottom

                              itemCount:
                                  allCategories.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == allCategories.length) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                return listDataWidget(
                                    context, allCategories, index);
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
            customNavBar(context)
          ],
        ),
      ),
    );
  }

  // List data widget with animations
  Padding listDataWidget(
      BuildContext context, List<FoodCategories> allCategories, int index) {
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
          child: listDataContentWidget(context, allCategories, index),
        ),
      ),
    );
  }

  Container listDataContentWidget(
      BuildContext context, List<FoodCategories> allCategories, int index) {
    return Container(
      width: 100,
      height: 173, // Adjust the height as needed
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.network(
                  hostNameMedia + allCategories[index].photo!.toString())
              .image,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DishesWidget(
                        category_id: allCategories[index].id.toString(),
                        category_name: allCategories[index].name.toString(),
                      ))); 
                      
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0x6E000000),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter, // Align to the bottom
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align text at the bottom
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allCategories[index].name!.toString(),
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(
                        height:
                            4), // Optional: space between the name and description
                    Text(
                      allCategories[index].description!.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
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
      _futureAllCategories = _fetchCategories();
    });
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

  @override
  void dispose() {
    // Cancel the debounce timer when widget is disposed
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
