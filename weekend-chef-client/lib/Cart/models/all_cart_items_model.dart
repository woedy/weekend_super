class AllCartItemsModel {
  String? message;
  Data? data;

  AllCartItemsModel({this.message, this.data});

  AllCartItemsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<CartItems>? cartItems;
  Pagination? pagination;

  Data({this.cartItems, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    // Handle cart_items being null
    if (json['cart_items'] != null) {
      cartItems = <CartItems>[];
      json['cart_items'].forEach((v) {
        cartItems!.add(CartItems.fromJson(v));
      });
    } else {
      cartItems = []; // If cart_items is null, set it to an empty list
    }

    // Handle pagination being null
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cartItems != null) {
      data['cart_items'] = cartItems!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class CartItems {
  int? id;
  String? dishName;
  String? dishCoverPhoto;
  int? quantity;
  String? category;
  double? itemTotalPrice; // Change type from int? to double?
  bool? isCustom;
  List<String>? parentCategoryNames;

  CartItems({
    this.id,
    this.dishName,
    this.dishCoverPhoto,
    this.quantity,
    this.category,
    this.itemTotalPrice, // Change type here as well
    this.isCustom,
    this.parentCategoryNames,
  });

  CartItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dishName = json['dish_name'];
    dishCoverPhoto = json['dish_cover_photo'];
    quantity = json['quantity'];
    category = json['category'];
    
    // Parse the itemTotalPrice as a double
    itemTotalPrice = json['item_total_price'] is int
        ? (json['item_total_price'] as int).toDouble() // Convert int to double if needed
        : json['item_total_price'].toDouble(); // Ensure it's a double

    isCustom = json['is_custom'];
    parentCategoryNames = List<String>.from(json['parent_category_names']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['dish_name'] = dishName;
    data['dish_cover_photo'] = dishCoverPhoto;
    data['quantity'] = quantity;
    data['category'] = category;
    
    // Ensure itemTotalPrice is a double when serializing
    data['item_total_price'] = itemTotalPrice;

    data['is_custom'] = isCustom;
    data['parent_category_names'] = parentCategoryNames;
    return data;
  }
}

class Pagination {
  int? pageNumber;
  int? totalPages;
  int? next;
  int? previous;

  Pagination({this.pageNumber, this.totalPages, this.next, this.previous});

  Pagination.fromJson(Map<String, dynamic> json) {
    pageNumber = json['page_number'];
    totalPages = json['total_pages'];
    next = json['next'];
    previous = json['previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    data['total_pages'] = totalPages;
    data['next'] = next;
    data['previous'] = previous;
    return data;
  }
}
