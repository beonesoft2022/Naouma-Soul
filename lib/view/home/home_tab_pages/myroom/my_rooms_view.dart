import 'dart:ui';

import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/common_functions.dart';
import 'package:project/models/follow_room_model.dart';

import 'package:project/utils/constants.dart';
import 'package:project/utils/preferences_services.dart';
import 'package:project/view/details/details_screen.dart';
import 'package:project/view/details/roomDetailsScreen.dart';
import 'package:project/view/home/homeCubit.dart';
import 'package:project/view/home/states.dart';
import 'package:project/widgets/my_rooms_item.dart';

class MyRoomsView extends StatelessWidget {
  MyRoomsView({Key key}) : super(key: key);
  RtcChannel _channel;
  RtcEngine _engine;
  ClientRole role = ClientRole.Broadcaster;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..followingroom(),
      child: BlocConsumer<HomeCubit, HomeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return ConditionalBuilder(
              condition: HomeCubit.get(context).followModel != null,
              builder: (context) => ListView.builder(
                  itemBuilder: (context, index) => buildroomItem(
                      HomeCubit.get(context).followModel.data[index]),
                  itemCount: HomeCubit.get(context).followModel.data.length),
              fallback: (context) => Container(
                color: Colors.white,
                child: Center(
                    child: Container(
                  child: Text(
                    "لم يتم الانضمام الي غرفة",
                    style: TextStyle(color: Colors.grey),
                  ),
                )),
              ),
            );
          }),
    );
  }

  buildroomItem(FollowModelData model) => Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              top: true,
              bottom: false,
              child: GestureDetector(
                onTap: () async {
                  Get.to(
                    DetailsScreen(
                      roomId: model.id.toString(),
                      roomDesc: model.roomDesc,
                      roomName: model.roomName,
                      userID: apiid,
                      roomImage: model.backgroundUrl + model.roomBackground,
                    ),
                    duration: Duration(milliseconds: 1000),
                  );
                },
                child: Container(

                    //add right and left padding
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8.0)),
                            child: Image.asset(
                              "assets/images/Profile Image.png",
                              // fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        // _sizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.flag),
                                  _sizedBox(width: 4.0),
                                  Expanded(
                                      child: Text(
                                    model.roomName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )),
                                ]),
                                _sizedBox(height: 6),
                                _sizedBox(height: 8),
                                Text(
                                  model.roomDesc,
                                  maxLines: 1,
                                  style: TextStyle(color: kPrimaryColor),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.perm_identity_sharp,
                                  size: 20,
                                ),
                                Text(
                                  model.id.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ],
                        ),
                        _sizedBox(width: 10),
                      ],
                    )),
              ),
            ),
          )
        ],
      );

  Widget _sizedBox({double width, double height}) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
