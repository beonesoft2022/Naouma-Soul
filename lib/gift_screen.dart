import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:project/common_functions.dart';
import 'package:project/dioHelper.dart';
import 'package:project/home.dart';
import 'package:project/models/get_wallet_model.dart';
import 'package:http/http.dart' as http;

import 'package:project/models/gift_model.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/models/roomUser.dart';
import 'package:project/models/room_data_model.dart';
import 'package:project/models/send_gift_model.dart';
import 'package:project/utils/constants.dart';
import 'package:project/view/details/users_Inroom.dart';
import 'package:project/view/home/homeCubit.dart';
import 'package:project/view/home/states.dart';

class GiftScreen extends StatefulWidget {
  String roomID;
  String userID;
  String username;
  bool check;

  GiftScreen({Key key, this.roomID, this.userID, this.username, this.check})
      : super(key: key);
  String type;
  String giftID;
  final GlobalKey _menuKey = GlobalKey();

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  // String dropdownvalue = 'sendToAllUser';
  var items = [
    'sendToAllUser',
    'sendToRoom',
    'sendToUser',
  ];

  var _controller = TextEditingController();
  int counter = 1;
  int selectedCard = -1;
  String dropDownValue = 'One';
  String senduserId;
  @override
  var fromkey = GlobalKey<FormState>();
  int index = 0;
  String newValue;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => HomeCubit()
          ..getWalletAmount()
          ..getGift()
          ..getroomuser(id: widget.roomID),
        child: BlocConsumer<HomeCubit, HomeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            _controller.text = counter.toString();

            return ConditionalBuilder(
              condition: HomeCubit.get(context).getWalletModel != null &&
                  HomeCubit.get(context).giftModel != null &&
                  HomeCubit.get(context).roomUserModel != null,
              builder: (context) => getIntresItem(
                  HomeCubit.get(context).giftModel,
                  context,
                  HomeCubit.get(context).getWalletModel.data,
                  HomeCubit.get(context).roomUserModel.data[index],
                  HomeCubit.get(context).roomUserModel,
                  index,
                  newValue,
                  dropDownValue),
              fallback: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.40,
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ));
  }

  Widget getIntresItem(
    GiftModel model,
    BuildContext context,
    GetWalletData model1,
    InRoomUserModelModelData model2,
    InRoomUserModelModel model3,
    int index,
    String newValue,
    String dropDownValue,
  ) =>
      Container(
        height: MediaQuery.of(context).size.height * 0.40,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Expanded for wallet amount
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: 30,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  model1.walletAmount.toString(),
                                  style:
                                      secondaryTextStyle(color: Colors.white),
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: model.data.length,
                  itemBuilder: (context, index) {
                    return buildGridleProduct(model.data[index], index);
                  },
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(27.0)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      DropdownButtonHideUnderline(
                        child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.grey.shade300,
                            ),
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return DropdownButton<String>(
                                    hint: Text(
                                      'اختر عضو',
                                      style: TextStyle(
                                          color: kPrimaryLightColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                    value: widget.check == true
                                        ? widget.username
                                        : newValue,
                                    items: List.generate(
                                        model3.data.length + 1,
                                        (index) => DropdownMenuItem(
                                            value: index < model3.data.length
                                                ? model3.data[index].name
                                                    .toString()
                                                : '-1',
                                            child: Center(
                                                child: Text(
                                              index < model3.data.length
                                                  ? model3.data[index].name ??
                                                      'Default Text' // Add null check here
                                                  : 'اختيار الكل',
                                              style: TextStyle(
                                                  // fontSize: 10,
                                                  color: Colors.blue),
                                            )))),
                                    onChanged: (String value) {
                                      // newValue = newValue;
                                      print(value);
                                      setState(() {
                                        newValue = value;
                                        senduserId = model3.data[index].userId
                                            .toString();

                                        print(
                                            '________________________$newValue');
                                        print(senduserId);
                                        widget.check = false;
                                        // print(model2.userId.toString());
                                      });
                                    });
                              },
                            )),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  height: 40,
                  width: 60,
                  // color: Colors.blue,
                  child: InkWell(
                    child: new Container(
                      decoration: new BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: new BorderRadius.only(
                          bottomLeft: const Radius.circular(40.0),
                          topLeft: const Radius.circular(40.0),
                        ),
                      ),
                      child: Center(
                          child: Text(
                        "إرسال",
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                    onTap: () {
                      if (senduserId == null) {
                        senduserId = widget.userID.toString();
                      }
                      // print('userID is${widget.userID}');
                      // print('userID is${widget.check}');
                      print('userID is $senduserId');
                      print('giftID is $giftID');
                      print('roomId is ${widget.roomID}');
                      print(_controller.text);
                      HomeCubit.get(context).sendgift(
                          id: widget.roomID,
                          type: 'user',
                          giftid: giftID,
                          received: senduserId.toInt(),
                          count: _controller.text);
                      // Call sendGiftToFirebase function
                      HomeCubit.get(context).sendGiftToFirebase(
                        roomId: widget.roomID,
                        giftId: giftID,
                        receiverId: senduserId,
                        count: _controller.text,
                      );
                      giftID = '0';

                      Navigator.pop(context);

                      // Show a SnackBar with an image
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     backgroundColor: Colors.transparent,
                      //     duration: Duration(seconds: 10),
                      //     content: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Center(
                      //           child: Image.network(
                      //             'https://nauma.smartlys.online/public/uploads/images/shop/VDMrqshf4qyScQJWEAXJ0D9huZto0exXdwmJSJJG.png',
                      //             fit: BoxFit.cover,
                      //           ),
                      //         ),
                      //         Text(
                      //           '0121212',
                      //           style: TextStyle(
                      //             fontSize: 30.0,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //         Text(
                      //           '222 قد استلم هدية',
                      //           style: TextStyle(
                      //             fontSize: 30.0,
                      //             color: Colors.white,
                      //             shadows: [
                      //               Shadow(
                      //                 blurRadius: 10.0,
                      //                 color: Colors.black,
                      //                 offset: Offset(5.0, 5.0),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
                Theme(
                  data: Theme.of(context)
                      .copyWith(splashColor: Color.fromARGB(227, 233, 7, 7)),
                  child: Container(
                    width: 130,
                    height: 40,
                    child: TextFormField(
                      controller: _controller,
                      autofocus: false,
                      style:
                          TextStyle(fontSize: 22.0, color: Color(0xFFbdc6cf)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: white,
                        prefixIcon: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (counter > 1) {
                              counter--;
                              _controller.text = counter.toString();
                              print(_controller.text);
                            }
                          },
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              counter++;
                              _controller.text = counter.toString();
                              print(_controller.text);
                            });
                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: KstorebuttonColor),
                          borderRadius: new BorderRadius.only(
                            bottomRight: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            )
          ],
        ),
      );

  Widget buildGridleProduct(GiftData model, int index) => Row(
        children: List.generate(3, (colIndex) {
          int cardIndex = index * 3 + colIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // ontap of each card, set the defined int to the grid view index
                  selectedCard = cardIndex;

                  giftID = model.id.toString();

                  print(giftID);
                });
              },
              child: SizedBox(
                width: 90.0,
                height: 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        selectedCard == cardIndex ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(8.0),
                      left: Radius.circular(8.0),
                    ),
                  ),
                  // check if the index is equal to the selected Card integer
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        child: Column(
                          children: [
                            Image.network(
                              (model.url ?? '') + model.giftLink,
                              width: 50,
                              height: 60,
                              // fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: KstorebuttonColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Center(child: Text(model.price.toString())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      );
}
