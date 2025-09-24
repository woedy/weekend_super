class AvailableChefsModel {
  String? message;
  Data? data;

  AvailableChefsModel({this.message, this.data});

  AvailableChefsModel.fromJson(Map<String, dynamic> json) {
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
  List<NearbyChefs>? nearbyChefs;

  Data({this.nearbyChefs});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['nearby_chefs'] != null) {
      nearbyChefs = <NearbyChefs>[];
      json['nearby_chefs'].forEach((v) {
        nearbyChefs!.add(new NearbyChefs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.nearbyChefs != null) {
      data['nearby_chefs'] = this.nearbyChefs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NearbyChefs {
  String? chefId;
  String? chefName;
  String? chefPhoto;
  String? kitchenLocation;
  double? lat;
  double? lng;
  double? distance;

  NearbyChefs(
      {this.chefId,
      this.chefName,
      this.chefPhoto,
      this.kitchenLocation,
      this.lat,
      this.lng,
      this.distance});

  NearbyChefs.fromJson(Map<String, dynamic> json) {
    chefId = json['chef_id'];
    chefName = json['chef_name'];
    chefPhoto = json['chef_photo'];
    kitchenLocation = json['kitchen_location'];
    lat = json['lat'];
    lng = json['lng'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chef_id'] = this.chefId;
    data['chef_name'] = this.chefName;
    data['chef_photo'] = this.chefPhoto;
    data['kitchen_location'] = this.kitchenLocation;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['distance'] = this.distance;
    return data;
  }
}
