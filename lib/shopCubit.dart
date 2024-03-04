/*
 * Copyright (c) 2023. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
 * Morbi non lorem porttitor neque feugiat blandit. Ut vitae ipsum eget quam lacinia accumsan.
 * Etiam sed turpis ac ipsum condimentum fringilla. Maecenas magna.
 * Proin dapibus sapien vel ante. Aliquam erat volutpat. Pellentesque sagittis ligula eget metus.
 * Vestibulum commodo. Ut rhoncus gravida arcu.
 */

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:project/endpoint.dart';
import 'package:project/models/permeim_model.dart';
import 'package:project/models/special_id_model.dart';
import 'package:project/shopStates.dart';
import 'package:project/utils/HedraTrace.dart';
import 'package:project/utils/constants.dart';

import 'common_functions.dart';
import 'dioHelper.dart';
import 'models/frames_model.dart';
import 'models/get_wallet_model.dart';
import 'models/myBackground_model.dart';
import 'models/perimem_puchase_model.dart';
import 'models/shop_background_mode.dart';
import 'models/shop_intres_model.dart';
import 'models/shop_purchase_model.dart';
import 'models/showLocks_model.dart';
import 'models/specialRoomID_model.dart';
import 'models/myInters_model.dart';
import 'package:http/http.dart' as http;
import 'package:project/network/cache_helper.dart';

class ShopCubit extends Cubit<ShopIntresStates> {
  ShopCubit() : super(ShopCubitIntialStates());
  HedraTrace hedra = HedraTrace(StackTrace.current);

  static ShopCubit get(context) => BlocProvider.of(context);
  String fimage = "";

  GetWalletModel getWalletModel;

  void getWalletAmount() {
    DioHelper.getdata(
            url: "$getwallet/${CacheHelper.getData(key: 'id')}", token: token)
        .then((value) {
      getWalletModel = GetWalletModel.fromJson(value.data);
      // print(value.data);
      emit(WalletSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(WalletErrorStates(error));
    });
  }

  //backend api checked
  IntresModel intresModel;

  void getIntresData() {
    emit(ShopIntresLoadingState());

    DioHelper.getdata(url: shopintre, token: token).then((value) {
      intresModel = IntresModel.fromJson(value.data);
      print(value.data);
      emit(ShopIntresSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(ShopIntresErrorStates(error));
    });
  }

  //backend api checked
  FramesModel framesModel;

  void getFramesData() {
    emit(FrameLoadingState());

    DioHelper.getdata(url: frame, token: token).then((value) {
      framesModel = FramesModel.fromJson(value.data);
      print("getFramesData" + value.data);
      emit(FrameSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(FrameErrorStates(error));
    });
  }

  //backend api checked
  BackgroundModel backgroundModel;

  void getBackgroundData() {
    emit(BackgroundLoadingStates());

    DioHelper.getdata(url: background, token: token).then((value) {
      backgroundModel = BackgroundModel.fromJson(value.data);
      print(value.data);
      emit(BackgroundSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(BackgroundErrorStates(error));
    });
  }

  //backend api checked
  MyBackgroundModel myBackgroundModel;

  void myBackgroundData() {
    emit(MyBackgroundLoadingStates());
    DioHelper.getdata(url: mybackground, token: token).then((value) {
      myBackgroundModel = MyBackgroundModel.fromJson(value.data);
      print(value.data);
      emit(MyBackgroundSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(MyBackgroundErrorStates(error));
    });
  }

  //backend api checked
  MyIntersModel myIntresModel;

  void myIntesData() {
    emit(MyIntesLoadingStates());
    DioHelper.getdata(url: myinters, token: token).then((value) {
      myIntresModel = MyIntersModel.fromJson(value.data);
      print(value.data);
      emit(MyIntesSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(MyIntesErrorStates(error));
    });
  }

  //backend api checked
  ShopPurchaseModel shopPurchaseModel;

  void shopPurchase({@required id}) {
    emit(ShopPurchaseLoadingStates());
    DioHelper.postdata(url: 'buy-new-product', token: token, data: {'id': id})
        .then((value) {
      print("id value of shopPurchaseModel is   " + value.data);

      if (value.data == "success") {
        emit(ShopPurchaseSuccessStates(ShopPurchaseModel.fromJson(value.data)));
      } else {
        emit(ShopPurchaseErrorStates(value.data));
      }
      shopPurchaseModel = ShopPurchaseModel.fromJson(value.data);
    }).catchError((error) {
      emit(ShopPurchaseErrorStates(error.toString()));
    });
  }

  void shopPurchase2({@required id}) async {
    emit(ShopPurchaseLoadingStates());

    try {
      final response = await DioHelper.postdata(
        url: 'buy-new-product',
        token: token,
        data: {'id': id},
      );
// Get data list
      final product = response.data['data'];

// Check that list is not empty
      if (product != null && product.isNotEmpty) {
        print("wooooooooooow is" + product.toString());
        emit(ShopPurchaseSuccessStates(ShopPurchaseModel.fromJson(product)));
      } else {
        // Show toast message
        Fluttertoast.showToast(
            msg: 'No data in API response',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      emit(
          ShopPurchaseSuccessStates(ShopPurchaseModel.fromJson(response.data)));

      CommonFunctions.showToast("Shop created in API ", Colors.greenAccent);
      //getx.Get.offAll(() => HomeScreen());
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      print(" - Error - There is Error in ${hedra.fileName} -- " +
          "In Line : ${hedra.lineNumber} -- " +
          "The caller function : ${hedra.callerFunctionName} -- " +
          "The Details is in create not fire: :::: " +
          e.toString() +
          " :::: " +
          "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  void ChangeDefaultBackground({@required shopid, @required roomid}) async {
    emit(ShopPurchaseLoadingStates());
    print("shopid is " + shopid.toString());
    print("roomid is " + roomid.toString());
    try {
      final response = await DioHelper.postdata(
        url: 'changebackground',
        token: token,
        data: {'room_id': roomid, 'background_id': shopid},
      );
      // Get data list
      final product = response.data['data'];

      // Check that list is not empty
      if (product != null) {
        print("wooooooooooow is" + response.toString());
        try {
          // Use the 'product' variable here
          emit(ShopPurchaseSuccessStates(
              ShopPurchaseModel.fromJson(response.data)));
        } catch (e) {
          print("Product is not a valid JSON string" + e.toString());
        }
      } else {
        // Show toast message
        Fluttertoast.showToast(
            msg: 'No data in API response',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      CommonFunctions.showToast("Shop created in API ", Colors.greenAccent);
      //getx.Get.offAll(() => HomeScreen());
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      print(" - Error - There is Error in ${hedra.fileName} -- " +
          "In Line : ${hedra.lineNumber} -- " +
          "The caller function : ${hedra.callerFunctionName} -- " +
          "The Details is in create not fire: :::: " +
          e.toString() +
          " :::: " +
          "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  void purchasePersonalID({@required id}) async {
    emit(PersonalPurchaseIDLoadingStates());

    try {
      final response = await DioHelper.postdata(
        url: 'buy-new-UserSpecialId',
        token: token,
        data: {'id': id},
      );
// Get data list
      final PurchaseID = response.data['data'];

// Check that list is not empty
      if (PurchaseID != null && PurchaseID.isNotEmpty) {
        print("wooooooooooow is" + PurchaseID.toString());
        emit(PersonalPurchaseIDSuccessStates());
      } else {
        // Show toast message
        Fluttertoast.showToast(
            msg: 'No data in API response',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      emit(PersonalPurchaseIDSuccessStates());

      CommonFunctions.showToast("Shop created in API ", Colors.greenAccent);
      //getx.Get.offAll(() => HomeScreen());
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      print(" - Error - There is Error in ${hedra.fileName} -- " +
          "In Line : ${hedra.lineNumber} -- " +
          "The caller function : ${hedra.callerFunctionName} -- " +
          "The Details is in create not fire: :::: " +
          e.toString() +
          " :::: " +
          "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  void purchaseRoomlID({@required id}) async {
    emit(PersonalPurchaseIDLoadingStates());

    try {
      final response = await DioHelper.postdata(
        url: 'buy-new-SpecialRoomID',
        token: token,
        data: {'id': id},
      );
// Get data list
      final PurchaseID = response.data['data'];

// Check that list is not empty
      if (PurchaseID != null && PurchaseID.isNotEmpty) {
        print("wooooooooooow is" + PurchaseID.toString());
        emit(PersonalPurchaseIDSuccessStates());
      } else {
        // Show toast message
        Fluttertoast.showToast(
            msg: 'No data in API response',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      emit(PersonalPurchaseIDSuccessStates());

      CommonFunctions.showToast("Shop created in API ", Colors.greenAccent);
      //getx.Get.offAll(() => HomeScreen());
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      print(" - Error - There is Error in ${hedra.fileName} -- " +
          "In Line : ${hedra.lineNumber} -- " +
          "The caller function : ${hedra.callerFunctionName} -- " +
          "The Details is in create not fire: :::: " +
          e.toString() +
          " :::: " +
          "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  SpecialIDModel specialIDModel;

  void mySpecialID() {
    emit(SpecialIDLoadingStates());

    DioHelper.getdata(url: specialid, token: token).then((value) {
      specialIDModel = SpecialIDModel.fromJson(value.data);
      print(value.data);
      print(specialIDModel.data.first.id);
      emit(SpecialIDSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(SpecialIDErrorStates(error));
    });
  }

  SpecialRoomIDModel specialRoomIDModel;

  void specialRoomID() {
    emit(SpecialRoomIDLoadingStates());

    DioHelper.getdata(url: specialRoomid, token: token).then((value) {
      specialRoomIDModel = SpecialRoomIDModel.fromJson(value.data);
      print(value.data);
      // print(specialIDModel.data.first.id);
      emit(SpecialRoomIDSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(SpecialRoomIDErrorStates(error));
    });
  }

  PermiemModel permiemModel;

  void getPermiemData() {
    emit(PermemLoadingState());

    DioHelper.getdata(url: permiem, token: token).then((value) {
      permiemModel = PermiemModel.fromJson(value.data);
      print(value.data);
      emit(PermemSuccessStates(permiemModel));
    }).catchError((error) {
      print(error.toString());
      emit(PermemErrorStates(error));
    });
  }

  PermiemPurchaseModel permiemPurchaseModel;

  void buyPermiemData({@required id}) {
    emit(BuyPermemLoadingState());
    print("id is " + id.toString());
    DioHelper.postdata(url: buypermiem, token: token, data: {'id': id})
        .then((value) {
      print(value.data);
      permiemPurchaseModel = PermiemPurchaseModel.fromJson(value.data);

      emit(BuyPermemSuccessStates());
    }).catchError((error) {
      emit(BuyPermemErrorStates(error.toString()));
    });
  }

  ShowLocksModel showLocksModel;

  void showLocks() {
    emit(RoomLocksLoadingState());
    DioHelper.getdata(url: roomlocks, token: token).then((value) {
      showLocksModel = ShowLocksModel.fromJson(value.data);
      print(value.data);
      emit(RoomLocksSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(RoomLocksErrorStates(error));
    });
  }

  void lockPurchase({@required id}) {
    emit(LockPurchaseLoadingState());
    DioHelper.getdata(url: 'room-locks/$id', token: token).then((value) {
      print(value.data);
      emit(LockPurchaseSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(LockPurchaseErrorStates(error));
    });
  }
}
