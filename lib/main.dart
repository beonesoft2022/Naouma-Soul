import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:project/dioHelper.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/network/cache_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:project/shopCubit.dart';
import 'package:project/test.dart';
import 'package:project/theme.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/preferences_services.dart';
import 'package:project/view/home/homeCubit.dart';
import 'package:project/view/home/home_screen.dart';
import 'package:project/view/home/states.dart';
import 'package:project/view/login/login_view.dart';
import 'package:project/view/login/logincubit.dart';
import 'package:project/view/profile/profile_cubit.dart';
import 'package:project/view/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'helper/binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PreferencesServices.init();
  var fcmtoken = await FirebaseMessaging.instance.getToken();
  fcm_token = fcmtoken;
  print('Hey, this is the FCM token: >> $fcmtoken');

  // Check Google Play Services availability
  DioHelper.init();
  await CacheHelper.init();

  // Get Some information from cache (has been saved in cache when user logged in)
  // By Abo Elkhier

  // Token of Api not firebase
  String token = CacheHelper.getData(key: 'token');

  Widget widget;
  print(token);

  if (token != null) {
    widget = HomeScreen();
  } else {
    widget = LoginView();
  }
  return runApp(MyApp(
    startwidget: widget,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Widget startwidget;

  // call sendLocation() every 10 seconds
  MyApp({this.startwidget}) {
    Timer.periodic(Duration(seconds: 1000), (timer) {
      sendLocation();
    });
  }

  // write a function to send current location to firestore database every 10 seconds
  void sendLocation() async {
    // 1. Check if location services are enabled:
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Inform the user and potentially guide them to settings
      return;
    }

    // 2. Check for existing permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // 3. Request permission if it's denied
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denial
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the 'denied forever' case
      return;
    }

    // 4. If permissions are granted, get the location:
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);

    //get the user mobile phone name

// 5. Send location to Firestore with UserID
    FirebaseFirestore.instance
        .collection('locations')
        .doc(userid)
        .collection('data')
        .add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'time': DateTime.now()
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LoginScreenCubit()),
          BlocProvider(create: (context) {
            HomeCubit homeCubit = HomeCubit();
            if (token != null && token.isNotEmpty) {
              print('Hey, this is the token: >> $token');
              homeCubit
                ..showfriends()
                ..addExperience()
                ..getmyroom();
            }
            return homeCubit;
          }),
          BlocProvider(create: (context) => ProfileCubit()..getprofile()),
          BlocProvider(
            create: (context) => ShopCubit()
              ..getWalletAmount()
              ..getIntresData()
              ..getFramesData()
              ..getBackgroundData()
              ..specialRoomID()
              ..mySpecialID()
              ..getPermiemData(),
          ),
        ],
        child: BlocConsumer<HomeCubit, HomeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'نعومة',
              theme: themeData(),
              initialBinding: Binding(),
              home: LoginView(),
              routes: {
                // '/home': (context) =>  HomeScreen(),
              },
            );
          },
        ));
  }
}
