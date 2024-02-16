class InRoomUserModelModel {
  List<InRoomUserModelModelData> data;
  String message;
  int status;

  InRoomUserModelModel({this.data, this.message, this.status});

  InRoomUserModelModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(InRoomUserModelModelData.fromJson(v));
      });
    } else {
      data = [];
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data.map((v) => v.toJson()).toList();
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class InRoomUserModelModelData {
  dynamic avatar;
  int userId;
  String name;
  String spacialId;
  List<Level> level;
  bool isFriend;
  List<Package> package;
  String typeUser;
  bool isPurchaseId;
  dynamic frame;
  dynamic frameUrl;
  dynamic avatarUrl;

  InRoomUserModelModelData({
    this.avatar,
    this.userId,
    this.name,
    this.spacialId,
    this.level,
    this.isFriend,
    this.package,
    this.typeUser,
    this.isPurchaseId,
    this.frame,
    this.frameUrl,
    this.avatarUrl,
  });

  InRoomUserModelModelData.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    userId = json['user_id'];
    name = json['name'];
    spacialId = json['spacial_id'];
    if (json['level'] != null) {
      level = [];
      json['level'].forEach((v) {
        level.add(Level.fromJson(v));
      });
    } else {
      level = [];
    }
    isFriend = json['is_friend'];
    if (json['package'] != null) {
      package = [];
      json['package'].forEach((v) {
        package.add(Package.fromJson(v));
      });
    } else {
      package = [];
    }
    typeUser = json['type_user'];
    isPurchaseId = json['is_purchase_id'];
    frame = json['frame'];
    frameUrl = json['frame_url'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = this.avatar;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['spacial_id'] = this.spacialId;
    data['level'] = this.level.map((v) => v.toJson()).toList();
    data['is_friend'] = this.isFriend;
    data['package'] = this.package.map((v) => v.toJson()).toList();
    data['type_user'] = this.typeUser;
    data['is_purchase_id'] = this.isPurchaseId;
    data['frame'] = this.frame;
    data['frame_url'] = this.frameUrl;
    data['avatar_url'] = this.avatarUrl;
    return data;
  }
}

// Continue with the Level, Package, and Pivot classes as before, but without the null safety features.
class Level {
  int id;
  int userId;
  int userCurrentExp;
  int userCurrentLevel;
  String createdAt;
  String updatedAt;

  Level({
    this.id,
    this.userId,
    this.userCurrentExp,
    this.userCurrentLevel,
    this.createdAt,
    this.updatedAt,
  });

  Level.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userCurrentExp = json['user_current_exp'];
    userCurrentLevel = json['user_current_level'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_current_exp'] = this.userCurrentExp;
    data['user_current_level'] = this.userCurrentLevel;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Package {
  int id;
  String name;
  String color;
  String badge;
  int price;
  String createdAt;
  String updatedAt;
  dynamic nameAr;
  String url;
  Pivot pivot;

  Package({
    this.id,
    this.name,
    this.color,
    this.badge,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.nameAr,
    this.url,
    this.pivot,
  });

  Package.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    badge = json['badge'];
    price = json['price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    nameAr = json['name_ar'];
    url = json['url'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['color'] = this.color;
    data['badge'] = this.badge;
    data['price'] = this.price;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name_ar'] = this.nameAr;
    data['url'] = this.url;
    if (this.pivot != null) {
      data['pivot'] = this.pivot.toJson();
    }
    return data;
  }
}

class Pivot {
  int userId;
  int packageId;
  String createdAt;
  String updatedAt;

  Pivot({
    this.userId,
    this.packageId,
    this.createdAt,
    this.updatedAt,
  });

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    packageId = json['package_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = this.userId;
    data['package_id'] = this.packageId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
