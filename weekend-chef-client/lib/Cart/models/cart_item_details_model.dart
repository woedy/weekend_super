class CartItemDetailsModel {
  String? message;
  Data? data;

  CartItemDetailsModel({this.message, this.data});

  CartItemDetailsModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? dishId;
  String? dish;
  String? coverPhoto;
  bool? isCustom;
  String? value;
  String? package;
  double? packagePrice;
  int? quantity;
  String? specialNotes;
  List<Customizations>? customizations;
  double? totalPrice;

  Data(
      {this.id,
      this.dishId,
      this.dish,
      this.coverPhoto,
      this.isCustom,
      this.value,
      this.package,
      this.packagePrice,
      this.quantity,
      this.specialNotes,
      this.customizations,
      this.totalPrice});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dishId = json['dish_id'];
    dish = json['dish'];
    coverPhoto = json['cover_photo'];
    isCustom = json['is_custom'];
    value = json['value'];
    package = json['package'];
    packagePrice = json['package_price'];
    quantity = json['quantity'];
    specialNotes = json['special_notes'];
    if (json['customizations'] != null) {
      customizations = <Customizations>[];
      json['customizations'].forEach((v) {
        customizations!.add(new Customizations.fromJson(v));
      });
    }
    totalPrice = json['total_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dish_id'] = this.dishId;
    data['dish'] = this.dish;
    data['cover_photo'] = this.coverPhoto;
    data['is_custom'] = this.isCustom;
    data['value'] = this.value;
    data['package'] = this.package;
    data['package_price'] = this.packagePrice;
    data['quantity'] = this.quantity;
    data['special_notes'] = this.specialNotes;
    if (this.customizations != null) {
      data['customizations'] =
          this.customizations!.map((v) => v.toJson()).toList();
    }
    data['total_price'] = this.totalPrice;
    return data;
  }
}

class Customizations {
  int? customOptionId;
  String? customizationOption;
  String? customizationPhoto;
  double? customizationPrice;
  int? quantity;

  Customizations(
      {this.customOptionId,
      this.customizationOption,
      this.customizationPhoto,
      this.customizationPrice,
      this.quantity});

  Customizations.fromJson(Map<String, dynamic> json) {
    customOptionId = json['custom_option_id'];
    customizationOption = json['customization_option'];
    customizationPhoto = json['customization_photo'];
    customizationPrice = json['customization_price'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['custom_option_id'] = this.customOptionId;
    data['customization_option'] = this.customizationOption;
    data['customization_photo'] = this.customizationPhoto;
    data['customization_price'] = this.customizationPrice;
    data['quantity'] = this.quantity;
    return data;
  }
}
