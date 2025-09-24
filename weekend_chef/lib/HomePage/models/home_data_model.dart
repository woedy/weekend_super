class HomeDataModel {
  String? message;
  Data? data;

  HomeDataModel({this.message, this.data});

  HomeDataModel.fromJson(Map<String, dynamic> json) {
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
  UserData? userData;
  int? notificationCount;
  List<DishCategories>? dishCategories;

  Data({this.userData, this.notificationCount, this.dishCategories});

  Data.fromJson(Map<String, dynamic> json) {
    userData = json['user_data'] != null
        ? new UserData.fromJson(json['user_data'])
        : null;
    notificationCount = json['notification_count'];
    if (json['dish_categories'] != null) {
      dishCategories = <DishCategories>[];
      json['dish_categories'].forEach((v) {
        dishCategories!.add(new DishCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userData != null) {
      data['user_data'] = this.userData!.toJson();
    }
    data['notification_count'] = this.notificationCount;
    if (this.dishCategories != null) {
      data['dish_categories'] =
          this.dishCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserData {
  String? userId;
  String? firstName;
  String? lastName;
  String? photo;

  UserData({this.userId, this.firstName, this.lastName, this.photo});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['photo'] = this.photo;
    return data;
  }
}

class DishCategories {
  int? id;
  String? name;
  String? photo;
  List<Dishes>? dishes;

  DishCategories({this.id, this.name, this.photo, this.dishes});

  DishCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
    if (json['dishes'] != null) {
      dishes = <Dishes>[];
      json['dishes'].forEach((v) {
        dishes!.add(new Dishes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['photo'] = this.photo;
    if (this.dishes != null) {
      data['dishes'] = this.dishes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dishes {
  int? id;
  String? name;
  String? coverPhoto;
  String? basePrice;
  String? value;
  bool? customizable;

  Dishes(
      {this.id,
      this.name,
      this.coverPhoto,
      this.basePrice,
      this.value,
      this.customizable});

  Dishes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coverPhoto = json['cover_photo'];
    basePrice = json['base_price'];
    value = json['value'];
    customizable = json['customizable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['cover_photo'] = this.coverPhoto;
    data['base_price'] = this.basePrice;
    data['value'] = this.value;
    data['customizable'] = this.customizable;
    return data;
  }
}
