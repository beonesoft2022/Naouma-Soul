import 'package:flutter/widgets.dart';

import '../../utils/constants.dart';
import 'homeCubit.dart';

class MyObserver extends WidgetsBindingObserver {
  final HomeCubit homeCubit;

  MyObserver(this.homeCubit);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Call the HomeCubit methods here
      homeCubit.patchfcmtoken(fcmtoken: fcm_token);
      homeCubit.showfriends();
      homeCubit.getmyroom();
    }
  }
}
