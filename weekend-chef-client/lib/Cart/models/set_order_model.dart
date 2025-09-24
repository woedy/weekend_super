class SetOrderModel {
  String? message;
  Data? data;
  Map<String, List<String>>? errors;

  SetOrderModel({this.message, this.data, this.errors});

  SetOrderModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    errors = json['errors'] != null ? _parseErrors(json['errors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['message'] = this.message;
    if (this.data != null) {
      dataMap['data'] = this.data!.toJson();
    }
    if (this.errors != null) {
      dataMap['errors'] = _toJsonErrors(this.errors!);
    }
    return dataMap;
  }

  // Helper method to parse errors (similar to how you did it in SignUpModel)
  static Map<String, List<String>> _parseErrors(Map<String, dynamic> errorData) {
    Map<String, List<String>> errors = {};
    errorData.forEach((key, value) {
      if (value is List) {
        errors[key] = List<String>.from(value);
      } else if (value is String) {
        errors[key] = [value];
      }
    });
    return errors;
  }

  // Helper method to convert errors back into a JSON-friendly format
  static Map<String, dynamic> _toJsonErrors(Map<String, List<String>> errors) {
    final Map<String, dynamic> errorsMap = {};
    errors.forEach((key, value) {
      errorsMap[key] = value;
    });
    return errorsMap;
  }
}

class Data {
  String? orderId;
  String? totalPrice;
  String? orderDate;
  String? deliveryDate;
  String? deliveryTime;
  String? status;
  bool? fastOrder;

  Data(
      {this.orderId,
      this.totalPrice,
      this.orderDate,
      this.deliveryDate,
      this.deliveryTime,
      this.status,
      this.fastOrder});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    totalPrice = json['total_price'];
    orderDate = json['order_date'];
    deliveryDate = json['delivery_date'];
    deliveryTime = json['delivery_time'];
    status = json['status'];
    fastOrder = json['fast_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['order_id'] = this.orderId;
    dataMap['total_price'] = this.totalPrice;
    dataMap['order_date'] = this.orderDate;
    dataMap['delivery_date'] = this.deliveryDate;
    dataMap['delivery_time'] = this.deliveryTime;
    dataMap['status'] = this.status;
    dataMap['fast_order'] = this.fastOrder;
    return dataMap;
  }
}

