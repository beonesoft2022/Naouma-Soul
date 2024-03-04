class ShopPurchaseModel {
  final Map<String, dynamic> data;
  final String message;
  final String status;

  ShopPurchaseModel({this.data, this.message, this.status});

  factory ShopPurchaseModel.fromJson(Map<String, dynamic> json) {
    return ShopPurchaseModel(
      data: json['data']['data'] != null ? json['data']['data'] : null,
      message: json['data']['message'],
      status: json['data']['status'],
    );
  }
}
