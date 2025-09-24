class DishesModel {
  String? message;
  Data? data;

  DishesModel({this.message, this.data});

  DishesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Dishes>? dishes;
  Pagination? pagination;

  Data({this.dishes, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['dishes'] != null) {
      dishes = <Dishes>[];
      json['dishes'].forEach((v) {
        dishes!.add(new Dishes.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dishes != null) {
      data['dishes'] = this.dishes!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Dishes {
  String? dishId;
  String? name;
  String? coverPhoto;
  String? description;
  String? smallPrice;
  String? categoryName;
  String? smallValue;

  Dishes(
      {this.dishId,
      this.name,
      this.coverPhoto,
      this.description,
      this.smallPrice,
      this.categoryName,
      this.smallValue});

  Dishes.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    coverPhoto = json['cover_photo'];
    description = json['description'];
    smallPrice = json['small_price'];
    categoryName = json['category_name'];
    smallValue = json['small_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['cover_photo'] = this.coverPhoto;
    data['description'] = this.description;
    data['small_price'] = this.smallPrice;
    data['category_name'] = this.categoryName;
    data['small_value'] = this.smallValue;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page_number'] = this.pageNumber;
    data['total_pages'] = this.totalPages;
    data['next'] = this.next;
    data['previous'] = this.previous;
    return data;
  }
}
