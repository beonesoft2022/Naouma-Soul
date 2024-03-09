class ShopByID {
  final Data data;
  final String message;
  final int status;

  ShopByID({this.data, this.message, this.status});

  factory ShopByID.fromJson(Map<String, dynamic> json) {
    return ShopByID(
      data: Data.fromJson(json['data']),
      message: json['message'],
      status: json['status'],
    );
  }
}

class Data {
  final String shopname;
  final String imageurl;

  Data({this.shopname, this.imageurl});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      shopname: json['shopname'],
      imageurl: json['imageurl'],
    );
  }
}
