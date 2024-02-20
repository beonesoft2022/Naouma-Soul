/*
 * Copyright (c) 2023. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
 * Morbi non lorem porttitor neque feugiat blandit. Ut vitae ipsum eget quam lacinia accumsan.
 * Etiam sed turpis ac ipsum condimentum fringilla. Maecenas magna.
 * Proin dapibus sapien vel ante. Aliquam erat volutpat. Pellentesque sagittis ligula eget metus.
 * Vestibulum commodo. Ut rhoncus gravida arcu.
 */

class MyBackgroundModel {
  List<MyBackgroundData> data;
  String message;
  int status;

  MyBackgroundModel({this.data, this.message, this.status});

  MyBackgroundModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MyBackgroundData>[];
      json['data'].forEach((v) {
        data.add(new MyBackgroundData.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class MyBackgroundData {
  int id;
  String name;
  String type;
  String giftLink;
  int price;
  String createdAt;
  String updatedAt;
  String url;

  MyBackgroundData(
      {this.id,
      this.name,
      this.type,
      this.giftLink,
      this.price,
      this.createdAt,
      this.updatedAt,
      this.url});

  MyBackgroundData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    giftLink = json['gift_link'];
    price = json['price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['gift_link'] = this.giftLink;
    data['price'] = this.price;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['url'] = this.url;
   
    return data;
  }
}

class Pivot {
  int userId;
  int shopId;

  Pivot({this.userId, this.shopId});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    shopId = json['shop_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['shop_id'] = this.shopId;
    return data;
  }
}
