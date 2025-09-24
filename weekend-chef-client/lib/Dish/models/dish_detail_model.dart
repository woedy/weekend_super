class DishDetailModel {
  String? message;
  Data? data;

  DishDetailModel({this.message, this.data});

  DishDetailModel.fromJson(Map<String, dynamic> json) {
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
  Dish? dish;
  List<RelatedFoods>? relatedFoods;
  List<Custom>? custom;
  List<Ingredients>? ingredients;

  Data({this.dish, this.relatedFoods, this.custom, this.ingredients});

  Data.fromJson(Map<String, dynamic> json) {
    dish = json['dish'] != null ? new Dish.fromJson(json['dish']) : null;
    if (json['related_foods'] != null) {
      relatedFoods = <RelatedFoods>[];
      json['related_foods'].forEach((v) {
        relatedFoods!.add(new RelatedFoods.fromJson(v));
      });
    }
    if (json['custom'] != null) {
      custom = <Custom>[];
      json['custom'].forEach((v) {
        custom!.add(new Custom.fromJson(v));
      });
    }
    if (json['ingredients'] != null) {
      ingredients = <Ingredients>[];
      json['ingredients'].forEach((v) {
        ingredients!.add(new Ingredients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dish != null) {
      data['dish'] = this.dish!.toJson();
    }
    if (this.relatedFoods != null) {
      data['related_foods'] =
          this.relatedFoods!.map((v) => v.toJson()).toList();
    }
    if (this.custom != null) {
      data['custom'] = this.custom!.map((v) => v.toJson()).toList();
    }
    if (this.ingredients != null) {
      data['ingredients'] = this.ingredients!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dish {
  String? dishId;
  String? name;
  String? description;
  String? smallPrice;
  String? smallValue;
  String? mediumPrice;
  String? mediumValue;
  String? largePrice;
  String? largeValue;
  String? coverPhoto;
  String? categoryName;
  int? quantity;
  bool? customizable;
  List<Ingredients>? ingredients;
  List<String>? parentCategoryNames;

  Dish(
      {this.dishId,
      this.name,
      this.description,
      this.smallPrice,
      this.smallValue,
      this.mediumPrice,
      this.mediumValue,
      this.largePrice,
      this.largeValue,
      this.coverPhoto,
      this.categoryName,
      this.quantity,
      this.customizable,
      this.ingredients,
      this.parentCategoryNames});

  Dish.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    description = json['description'];
    smallPrice = json['small_price'];
    smallValue = json['small_value'];
    mediumPrice = json['medium_price'];
    mediumValue = json['medium_value'];
    largePrice = json['large_price'];
    largeValue = json['large_value'];
    coverPhoto = json['cover_photo'];
    categoryName = json['category_name'];
    quantity = json['quantity'];
    customizable = json['customizable'];
    if (json['ingredients'] != null) {
      ingredients = <Ingredients>[];
      json['ingredients'].forEach((v) {
        ingredients!.add(new Ingredients.fromJson(v));
      });
    }
    parentCategoryNames = json['parent_category_names'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['small_price'] = this.smallPrice;
    data['small_value'] = this.smallValue;
    data['medium_price'] = this.mediumPrice;
    data['medium_value'] = this.mediumValue;
    data['large_price'] = this.largePrice;
    data['large_value'] = this.largeValue;
    data['cover_photo'] = this.coverPhoto;
    data['category_name'] = this.categoryName;
    data['quantity'] = this.quantity;
    data['customizable'] = this.customizable;
    if (this.ingredients != null) {
      data['ingredients'] = this.ingredients!.map((v) => v.toJson()).toList();
    }
    data['parent_category_names'] = this.parentCategoryNames;
    return data;
  }
}

class Ingredients {
  String? ingredientId;
  String? name;
  String? photo;

  Ingredients({this.ingredientId, this.name, this.photo});

  Ingredients.fromJson(Map<String, dynamic> json) {
    ingredientId = json['ingredient_id'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ingredient_id'] = this.ingredientId;
    data['name'] = this.name;
    data['photo'] = this.photo;
    return data;
  }
}

class RelatedFoods {
  String? dishId;
  String? name;
  String? coverPhoto;
  String? description;
  String? smallPrice;
  String? categoryName;

  RelatedFoods(
      {this.dishId,
      this.name,
      this.coverPhoto,
      this.description,
      this.smallPrice,
      this.categoryName});

  RelatedFoods.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    coverPhoto = json['cover_photo'];
    description = json['description'];
    smallPrice = json['small_price'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['cover_photo'] = this.coverPhoto;
    data['description'] = this.description;
    data['small_price'] = this.smallPrice;
    data['category_name'] = this.categoryName;
    return data;
  }
}

class Custom {
  String? customOptionId;
  String? name;
  String? photo;
  String? price;
  int quantity; // Local quantity to manage for customization

  Custom({
    this.customOptionId,
    this.name,
    this.photo,
    this.price,
    this.quantity = 0, // Default to 0 if quantity isn't provided
  });

  Custom.fromJson(Map<String, dynamic> json) : quantity = 0 {
    customOptionId = json['custom_option_id'];
    name = json['name'];
    photo = json['photo'];
    price = json['price'];
    // Notice that 'quantity' is not coming from the server, we initialize it to 0
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['custom_option_id'] = this.customOptionId;
    data['name'] = this.name;
    data['photo'] = this.photo;
    data['price'] = this.price;
    data['quantity'] =
        this.quantity; // Include the local quantity when sending data back
    return data;
  }
}
