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
  int? cartItemCount;
  List<Popular>? popular;

  Data(
      {this.userData,
      this.notificationCount,
      this.dishCategories,
      this.cartItemCount,
      this.popular});

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
    cartItemCount = json['cart_item_count'];
    if (json['popular'] != null) {
      popular = <Popular>[];
      json['popular'].forEach((v) {
        popular!.add(new Popular.fromJson(v));
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
    data['cart_item_count'] = this.cartItemCount;
    if (this.popular != null) {
      data['popular'] = this.popular!.map((v) => v.toJson()).toList();
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

  DishCategories({this.id, this.name, this.photo});

  DishCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['photo'] = this.photo;
    return data;
  }
}

class Popular {
  String? dishId;
  String? name;
  String? coverPhoto;
  String? smallPrice;
  String? smallValue;
  bool? customizable;
  String? description;

  Popular(
      {this.dishId,
      this.name,
      this.coverPhoto,
      this.smallPrice,
      this.smallValue,
      this.customizable,
      this.description});

  Popular.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    coverPhoto = json['cover_photo'];
    smallPrice = json['small_price'];
    smallValue = json['small_value'];
    customizable = json['customizable'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['cover_photo'] = this.coverPhoto;
    data['small_price'] = this.smallPrice;
    data['small_value'] = this.smallValue;
    data['customizable'] = this.customizable;
    data['description'] = this.description;
    return data;
  }
}
