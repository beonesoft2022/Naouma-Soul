import 'dart:async';

import 'dart:io';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:project/utils/HedraTrace.dart';

// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/audiocall.dart';
import 'package:project/common_functions.dart';
import 'package:project/endpoint.dart';
import 'package:project/models/IsFollow_model.dart';
import 'package:project/models/firebase_room_model.dart';
import 'package:project/models/get_user_exp_model.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/models/roomUser.dart';
import 'package:project/models/room_index.dart';
import 'package:project/models/room_user_model.dart';
import 'package:project/models/send_gift_model.dart';
import 'package:project/models/user_mic_model.dart';
import 'package:project/oneTo_one_screen.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/images.dart';
import 'package:project/utils/preferences_services.dart';
import 'package:project/view/details/components/roomImageTap.dart';
import 'package:project/view/details/users_Inroom.dart';
import 'package:project/view/home/homeCubit.dart';
import 'package:project/view/home/home_tab_pages/myroom/room_setting.dart';
import 'package:project/view/home/states.dart';

// import 'package:agora_rtm/agora_rtm.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../gift_screen.dart';
import '../../models/firebaseModel.dart';
import '../../models/mics_model.dart';
import '../../shop_background_gift.dart';
import '../../utils/size_config.dart';
import 'components/mic_click_dialog.dart';

/// DetailsScreen is a StatefulWidget that represents the screen showing the details for a room.
///
/// It contains the username, userID, roomId, roomImage, roomName, roomDesc, roomOwnerId, passwordRoom, apiroomID, and role
/// passed in from the my_rooms_view screen.
///
/// It manages the state for this screen via the _DetailsScreenState class.
class DetailsScreen extends StatefulWidget {
  //// Data Has Been Send From my_rooms_view.dart
  //// By Hedra Adel

  final String username;
  final String userID;
  final String roomId;
  final String roomImage;
  var e = StateError("This is a state error.");

  final String roomName;
  final String roomDesc;
  final String roomOwnerId;
  final String passwordRoom;
  final String apiroomID;

  // final ClientRole role;

  DetailsScreen(
      {Key key,
      this.username,
      this.userID,
      // this.role,
      this.roomId,
      this.roomName,
      this.roomDesc,
      this.roomOwnerId,
      this.apiroomID,
      this.passwordRoom,
      this.roomImage})
      : super(key: key);
  int _remoteUid;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  //// Model have : userid,spacialid,Relation with Level , isfriend,relation with Package , typeuser(Don’t know),
  //// isPurchaseid(Don’t know),frame,frameurl,avatar,avatarurl
  //// By Hedra Adel

  InRoomUserModelModel inRoomUserModelModel;

  // RtcEngine _engine;
  static final _users = <int>[];

  bool _isSpeaking = false;

  // AgoraRtmClient _client;
  // AgoraRtmChannel _channel;
  // AgoraRtmChannel _subchannel;
  bool get isSpeaking => _isSpeaking;

  String myChannel = '';
  bool _isChannelCreated = true;
  final _channelFieldController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  List<QueryDocumentSnapshot> roomUsersList = new List.from([]);
  final Map<String, List<String>> _seniorMember = {};
  final Map<String, int> _channelList = {};
  List<UserMicModel> _micUsersList = [];
  final _infoStrings = <String>[];
  String groupChatId = "";
  String roomID = "";
  int _roomUsersCount = 0;
  bool _isLoadingMics = true;
  bool _isLogin = false;
  bool _isInChannel = false;
  String isHaveFrame = '1';
  bool mute = true;
  int micnum;
  int micIndex = 3;
  bool onmic = false;
  int check;
  String message;
  String background;
  RoomModel roomModel;
  String totalnum;
  int limit = 20;
  final _firestoreInstance = FirebaseFirestore.instance;
  File imageFile;
  bool _isRoomOnFirebase = false;
  var expmodel;
  DocumentSnapshot snapshot; //Define snapshot
  HedraTrace hedra = HedraTrace(StackTrace.current);
  final _firestore = FirebaseFirestore.instance;

  void showGiftDialog(Map<String, dynamic> giftData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(giftData['imageUrl']),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Dialog closed, add any actions if needed
    });
    // Auto-close after 10 minutes
    Future.delayed(Duration(minutes: 10), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    print("room image is : ${widget.roomImage}");
    super.initState();

    try {
      //  showBackgroundDialog();
      isUserMuted();
      print("room image is : ${widget.roomImage}");
      countUsersInRoomAndUpdate();
      setRoomID();
      initialize();
      setState(() {});
      print("initState has been completed and the  " +
          "roomId: $roomID" +
          "--- Hedra Adel ---");
    } catch (e) {
      print('Error occurred in initState: $e');
    }
  }

// write a method to display for five seconds an transparent background image as fullscreen with text "يارب" wrote under it ,

// write a method to display for five seconds an transparent background image as fullscreen with text "يارب" wrote under it ,
  Future<void> showBackgroundDialog() async {
    String background222 = "https://onoo.online/bosh.gif";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(background222),
            ],
          ),
        );
      },
    ).then((_) {
      // Navigator.of(context).pop();
    });
    // Auto-close after 10 minutes
    Future.delayed(Duration(seconds: 10), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> initialize() async {
    //// Check the room is found or no in the firestore and update _isRoomOnFirebase bool variable
    //// By Hedra Adel
    try {
      await checkRoomFoundOrNot();
      //call showBackgroundDialog

      // write code listen to firebase realtime (roomNotifications/roomid) and fire showBackgroundDialog when new data is inserted
      // Get a reference to your desired node
      final roomNotificationsRef =
          FirebaseDatabase.instance.ref('roomNotifications/$roomID');

      // Listen for new data (assuming 'data' contains the notification payload)
      roomNotificationsRef.onChildAdded.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          showBackgroundDialog();
        }
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(
          " - Error - There is Error in initialize() in ${hedra.fileName} -- " +
              "In Line : ${hedra.lineNumber} -- " +
              "The caller function : ${hedra.callerFunctionName} -- " +
              "The Details is : :::: " +
              e.toString() +
              " :::: " +
              "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }

    // initialize agora
    // await _initAgoraRtcEngine();
    // _addAgoraEventHandlers();
    // await _engine.joinChannel(
    //     "00645f4567598af4f32afca701cccd0cf2dIADRIb4LxYD/WX4B1uQnZIJqrURDf6xrB/V2mFU7a+SDTwnn9jMAAAAAEAD+bihbcUpCYQEAAQCfyEJh",
    //     // "naoumaRoom",
    //     "${widget.roomName}",
    //     null,
    //     0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _users.clear();
    // destroy sdk

    // _engine.leaveChannel();
    print("The Room has Been Closed" + "--- Hedra Adel ---");
    // _engine.destroy();
    super.dispose();
  }

  /// Widget for displaying a person in the room.
  ///
  /// This widget represents a person in the room with their microphone status and profile image.
  /// It also handles various actions such as taking the microphone, leaving the microphone, and locking/unlocking the microphone.
  ///
  /// Parameters:
  /// - [index]: The index of the person in the room.
  /// - [micModel]: The model containing the microphone information for the person.
  ///
  /// Returns:
  /// The widget representing the person in the room.

  Widget RoomMicsWidget(int index, UserMicModel micModel) {
    print("_personInRoom index" + "$index" + "--- Hedra Adel ---");
    print(
        "_personInRoom index" + "${micModel.userName}" + "--- Hedra Adel ---");

    if (micModel != null) {
      return Container(
        child: Column(
          children: <Widget>[
            micModel.micStatus == true
                ? Expanded(
                    child: Row(
                      children: [
                        hasFrame == null
                            ? Container(
                                //empty frame
                                )
                            : Expanded(
                                child: Container(
                                    width: 7,
                                    child: Image.network(
                                      hasFrame,
                                    )),
                              ), // Back image
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            width: 50,
                            child: Image.asset(
                              "assets/images/Profile Image.png",
                              // fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: kPrimaryColor)),
                      child: Icon(
                        micModel.isLocked != null
                            ? micModel.isLocked
                                ? Icons.lock
                                : Icons.mic
                            : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
            2.height,
            Text(
              micModel.isLocked != null && micModel.isLocked
                  ? "مقفل"
                  : micModel.micStatus
                      ? micModel.userName.length > 7
                          ? ".${micModel.userName}"
                          : micModel.userName
                      : "${index + 1}",
              overflow: TextOverflow.ellipsis,
              style: secondaryTextStyle(size: 12, color: black),
            ),
          ],
        ),
      ).onTap(() {
        if (ismuted == false) {
          CommonFunctions.showToast('لا تملك الصلاحية', Colors.red);
        } else if (!micModel.micStatus &&
            !micModel.isLocked &&
            micModel.userId == null &&
            micModel.roomOwnerId == userid) {
          // Iam room owner and mic is empty
          print("Iam owner and mic is empty.");

          // Check if user already holds mic before
          var existingItem = _micUsersList.firstWhere(
              (itemToCheck) => itemToCheck.userId == userid,
              orElse: () => null);

          // user already holds mic before
          // will leave the old mic , and use new one

          if (existingItem != null) {
            print(existingItem.micNumber);
            print(existingItem.userName);
            print("take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(
                    takeMicFunction: () {
                      print("clicked take");
                      print("clicked index: $index");
                      // leave old mic
                      existingItem.id = null;
                      existingItem.userName = null;
                      existingItem.userId = null;
                      existingItem.micNumber = existingItem.micNumber;
                      existingItem.micStatus = false;
                      _updateMicsToFirebase(
                          existingItem.micNumber, existingItem);
                      print("existname: ${existingItem.userName}");
                      print("existuserId: ${existingItem.userId}");
                      print("existmicNumber: ${existingItem.micNumber}");
                      print("existid: ${existingItem.micNumber}");
                      print("existmicStatus: ${existingItem.micStatus}");

                      // go to new mic
                      micModel.id = index.toString();
                      micModel.userName = username;
                      micModel.userId = userid;
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");

                      /// Removes all previous screens from the back stack and redirect to new screen with provided screen tag
                      finish(context);

                      _updateMicsToFirebase(index, micModel);
                    },
                    leaveMicFunction: () {
                      // Leave mic
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    lockMicFunction: () {
                      // lock mic
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    unLockMicFunction: () {},
                    showTakeMic: true,
                    showLeaveMic: false,
                    showLockMic: true,
                    micIsLocked: false,
                  );
                });
          } else {
            print("not take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(
                    takeMicFunction: () {
                      // go to new mic
                      micModel.id = index.toString();
                      micModel.userName = username;
                      micModel.userId = userid;
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    leaveMicFunction: () {
                      // Leave mic
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    lockMicFunction: () {
                      // lock mic
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    unLockMicFunction: () {},
                    showTakeMic: true,
                    showLeaveMic: false,
                    showLockMic: true,
                    micIsLocked: false,
                  );
                });
          }
        } else if (!micModel.micStatus &&
            micModel.isLocked &&
            micModel.userId == null &&
            micModel.roomOwnerId == userid) {
          // Iam room owner and mic is locked
          print("Iam room owner and mic is locked...");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MicClickDialog(
                  takeMicFunction: () {},
                  leaveMicFunction: () {
                    // Leave mic
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    micModel.isLocked = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    _updateMicsToFirebase(index, micModel);
                    finish(context);
                  },
                  unLockMicFunction: () {
                    print("unLock Mic index: $index");
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    micModel.isLocked = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    _updateMicsToFirebase(index, micModel);
                    finish(context);
                  },
                  showTakeMic: false,
                  showLeaveMic: false,
                  showLockMic: false,
                  micIsLocked: true,
                );
              });
        } else if (micModel.micStatus &&
            !micModel.isLocked &&
            micModel.userId == userid &&
            micModel.roomOwnerId == userid) {
          // Iam room owner and mic is locked
          print("Iam room owner and mic is taken by me...");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MicClickDialog(
                  takeMicFunction: () {},
                  leaveMicFunction: () {
                    print("unLock Mic index: $index");
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    micModel.isLocked = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    _updateMicsToFirebase(index, micModel);
                    finish(context);
                  },
                  unLockMicFunction: () {},
                  showTakeMic: false,
                  showLeaveMic: true,
                  showLockMic: false,
                  micIsLocked: false,
                );
              });
        } else if (!micModel.micStatus &&
            !micModel.isLocked &&
            micModel.userId == null &&
            micModel.roomOwnerId != specialId) {
          // Iam not room owner and mic is locked
          print("Iam not room owner and mic is taken by me...");
          var existingItem = _micUsersList.firstWhere(
              (itemToCheck) => itemToCheck.userId == userid,
              orElse: () => null);
          if (existingItem != null) {
            // user already holds mic before
            print(existingItem.micNumber);
            print(existingItem.userName);
            print("take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(
                    takeMicFunction: () {
                      print("clicked take");
                      print("clicked index: $index");
                      // leave old mic
                      existingItem.id = null;
                      existingItem.userName = null;
                      existingItem.userId = null;
                      existingItem.micNumber = existingItem.micNumber;
                      existingItem.micStatus = false;
                      _updateMicsToFirebase(
                          existingItem.micNumber, existingItem);
                      print("existname: ${existingItem.userName}");
                      print("existuserId: ${existingItem.userId}");
                      print("existmicNumber: ${existingItem.micNumber}");
                      print("existid: ${existingItem.micNumber}");
                      print("existmicStatus: ${existingItem.micStatus}");

                      // go to new mic
                      micModel.id = index.toString();
                      micModel.userName = username;
                      micModel.userId = userid;
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      // update firebase
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    leaveMicFunction: () {
                      print("leave index: $index");
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      // update firebase
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    lockMicFunction: () {},
                    unLockMicFunction: () {},
                    showTakeMic: true,
                    showLeaveMic: true,
                    showLockMic: false,
                    micIsLocked: false,
                  );
                });
          } else {
            print("not take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(
                    takeMicFunction: () {
                      // go to new mic
                      micModel.id = index.toString();
                      micModel.userName = username;
                      micModel.userId = specialId.toString();
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    leaveMicFunction: () {
                      // Leave mic
                      micModel.id = null;
                      micModel.userName = null;
                      micModel.userId = null;
                      micModel.micNumber = index;
                      micModel.micStatus = false;
                      micModel.isLocked = false;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      _updateMicsToFirebase(index, micModel);
                      finish(context);
                    },
                    lockMicFunction: () {},
                    unLockMicFunction: () {},
                    showTakeMic: true,
                    showLeaveMic: true,
                    showLockMic: false,
                    micIsLocked: false,
                  );
                });
          }
        } else if (micModel.micStatus == true &&
            !micModel.isLocked &&
            micModel.userId != null &&
            micModel.userId == specialId) {
          // mic taken by me...
          print("mic taken by me...");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MicClickDialog(
                  takeMicFunction: () {},
                  leaveMicFunction: () {
                    print("leave index: $index");
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    finish(context);
                    _updateMicsToFirebase(index, micModel);
                  },
                  lockMicFunction: () {},
                  unLockMicFunction: () {},
                  showLockMic: false,
                  micIsLocked: false,
                  showTakeMic: false,
                  showLeaveMic: true,
                );
              });
        } else if (micModel.micStatus &&
            !micModel.isLocked &&
            micModel.userId != null &&
            micModel.userId != specialId) {
          // taken by other one
          CommonFunctions.showToast("Mic already taken", Colors.red);
        } else if (!micModel.micStatus &&
            micModel.isLocked &&
            micModel.userId != null &&
            micModel.userId != userid) {
          // Mic is locked
          CommonFunctions.showToast("Mic is locked", Colors.red);
        } else {
          print("_micUsersList: ${_micUsersList.length}");
          //find existing item per link criteria
          var existingItem = _micUsersList.firstWhere(
              (itemToCheck) => itemToCheck.userId == userid,
              orElse: () => null);
          if (existingItem != null) {
            // user already holds mic before
            print(existingItem.micNumber);
            print(existingItem.userName);
            print("take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(takeMicFunction: () {
                    print("clicked take");
                    print("clicked index: $index");
                    // leave old mic
                    existingItem.id = null;
                    existingItem.userName = null;
                    existingItem.userId = null;
                    existingItem.micNumber = existingItem.micNumber;
                    existingItem.micStatus = false;
                    _updateMicsToFirebase(existingItem.micNumber, existingItem);
                    print("existname: ${existingItem.userName}");
                    print("existuserId: ${existingItem.userId}");
                    print("existmicNumber: ${existingItem.micNumber}");
                    print("existid: ${existingItem.micNumber}");
                    print("existmicStatus: ${existingItem.micStatus}");

                    // go to new mic
                    micModel.id = index.toString();
                    micModel.userName = username;
                    micModel.userId = userid;
                    micModel.micNumber = index;
                    micModel.micStatus = true;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    finish(context);
                    _updateMicsToFirebase(index, micModel);
                  }, leaveMicFunction: () {
                    // Leave mic
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    micModel.isLocked = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    _updateMicsToFirebase(index, micModel);
                    finish(context);
                  });
                });
          } else {
            print("not take other mic");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MicClickDialog(takeMicFunction: () {
                    print("clicked take");
                    print("clicked index: $index");
                    micModel.id = "$index";
                    micModel.userName = username;
                    micModel.userId = userid;
                    micModel.micNumber = index;
                    micModel.micStatus = true;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    finish(context);
                    _updateMicsToFirebase(index, micModel);
                  }, leaveMicFunction: () {
                    // Leave mic
                    micModel.id = null;
                    micModel.userName = null;
                    micModel.userId = null;
                    micModel.micNumber = index;
                    micModel.micStatus = false;
                    micModel.isLocked = false;
                    print("name: ${micModel.userName}");
                    print("userId: ${micModel.userId}");
                    print("micNumber: ${micModel.micNumber}");
                    print("id: ${micModel.micNumber}");
                    print("micStatus: ${micModel.micStatus}");
                    _updateMicsToFirebase(index, micModel);
                    finish(context);
                  });
                });
          }
        }
      });
    } else {
      print("_personInRoom index" +
          "${micModel.userName}" +
          "--- Hedra Adel ---");
      print("_personInRoom index" +
          "${micModel.userName}" +
          "--- Hedra Adel ---");
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      TextEditingController _controller = TextEditingController();

      return BlocProvider(
        create: (context) => HomeCubit()
          ..getnotification(id: widget.roomId, password: widget.passwordRoom)
          ..getroomuser(id: widget.roomId)
          ..getuserExp(id: apiid)
          ..usersfollowingroom(id: widget.roomId),
        child: BlocConsumer<HomeCubit, HomeStates>(listener: (context, state) {
          if (state is SetPasswordRoomSuccessStates) {
            CommonFunctions.showToast('تم تعين كلمة مرور للغرفة', Colors.green);
          }
          if (state is InroomSuccessStates) {
            var model = HomeCubit.get(context).roomUserModel.message;
          }

          StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child('roomNotifications')
                .child(roomID)
                .onChildAdded,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Display text when new data is inserted
                return Text('New data inserted');
              } else {
                return Container();
              }
            },
          );

          if (state is NotificationSuccessStates) {
            var model = HomeCubit.get(context).notificationModel;
            var model1 = HomeCubit.get(context).roomUserModel;
            message = model1.message;
            check = model.data.user.follow;
            background = model.data.user.background;

            FirebaseMessaging.onMessage.listen((event) {
              print(
                  "FirebaseMessaging.onMessage NotificationSuccessStates event listen Has been fired data is " +
                      event.data.toString() +
                      "--- Hedra Adel ---");

              FirebaseModel firebaseModel;
              firebaseModel = FirebaseModel.fromJson(event.data);
              // isHaveFrame = null;
              // if (model.data.user.entry == 'ther is no entry') {
              // } else {
              // if (notfication == true) {
              //   print('>>>>>>>>>>>>>>>>>>>>>>>>');
              new Future.delayed(Duration.zero, () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Future.delayed(Duration(seconds: 5), () {
                        Navigator.of(context).pop(true);
                      });
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: new Container(
                            alignment: FractionalOffset.center,
                            // height: 80.0,
                            // padding: const EdgeInsets.all(20.0),
                            child: new Image.network(
                              firebaseModel.image,
                              fit: BoxFit.cover,
                            )),
                      );
                    });
              });
            });
          }
          // if (state is SendGiftSuccessStates) {
          //   var model = HomeCubit.get(context).notificationModel;
          //   String showgift =
          //       'https://nauma.onoo.online/public/uploads/images/shop/VDMrqshf4qyScQJWEAXJ0D9huZto0exXdwmJSJJG.png}'; // Ensure showgift is defined
          //
          //   FirebaseMessaging.onMessage.listen((event) {
          //     print(
          //         "FirebaseMessaging.onMessage SendGiftSuccessStates event listen Has been fired data is " +
          //             event.data.toString() +
          //             "--- Hedra Adel ---");
          //     SendgiftModel sendgiftModel;
          //     sendgiftModel = SendgiftModel.fromJson(event.data);
          //
          //     new Future.delayed(Duration.zero, () {
          //       showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             Future.delayed(Duration(seconds: 5), () {
          //               Navigator.of(context).pop(true);
          //             });
          //             return Dialog(
          //               backgroundColor: Colors.transparent,
          //               child: new Container(
          //                   alignment: FractionalOffset.center,
          //                   child: new Image.network(
          //                     showgift,
          //                     fit: BoxFit.cover,
          //                   )),
          //             );
          //           });
          //     });
          //   });
          // }
          // if (state is SendGiftSuccessStates) {
          //   var model = HomeCubit.get(context).notificationModel;
          //
          //   FirebaseMessaging.onMessage.listen((event) {
          //     print(
          //         "FirebaseMessaging.onMessage SendGiftSuccessStates event listen Has been fired data is " +
          //             event.data.toString() +
          //             "--- Hedra Adel ---");
          //     SendgiftModel sendgiftModel;
          //     sendgiftModel = SendgiftModel.fromJson(event.data);
          //     // isHaveFrame = null;
          //
          //     new Future.delayed(Duration.zero, () {
          //       showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             Future.delayed(Duration(seconds: 5), () {
          //               Navigator.of(context).pop(true);
          //             });
          //             return Dialog(
          //               backgroundColor: Colors.transparent,
          //               child: new Container(
          //                   alignment: FractionalOffset.center,
          //                   // height: 80.0,
          //                   // padding: const EdgeInsets.all(20.0),
          //                   child: new Image.network(
          //                     showgift,
          //                     fit: BoxFit.cover,
          //                   )),
          //             );
          //           });
          //     });
          //   });
          // }

          if (state is FollowSuccessStates) {
            if (HomeCubit.get(context).isFollowModel.success == true) {
              CommonFunctions.showToast('تم الانضام للغرفة', Colors.green);
            }
          }
        }, builder: (context, state) {
          return Stack(
            children: [
              ConditionalBuilder(
                condition: HomeCubit.get(context).roomUserModel != null &&
                    HomeCubit.get(context).getUserExpModel != null,
                builder: (context) {
                  try {
                    // Call getdata function with necessary parameters
                    print("Result of roomUserModel.message : " +
                        HomeCubit.get(context)
                            .roomUserModel
                            .message
                            .toString());
                    print("Result of roomUserModel: " +
                        HomeCubit.get(context).roomUserModel.toString());

                    return getdata(
                        constraints,
                        HomeCubit.get(context).getUserExpModel,
                        HomeCubit.get(context).roomUserModel.message.toString(),
                        HomeCubit.get(context).roomUserModel,
                        _controller);
                  } catch (e) {
                    // If any error occurs during the execution of the code, it is caught here
                    // The error message is then printed to the console
                    print('Error occurred in builder: $e');
                    return Container(); // Return an empty container in case of error
                  }
                },
                fallback: (context) {
                  try {
                    // Return a Container with a CircularProgressIndicator in the center
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } catch (e) {
                    // If any error occurs during the execution of the code, it is caught here
                    // The error message is then printed to the console
                    print('Error occurred in fallback: $e');
                    return Container(); // Return an empty container in case of error
                  }
                },
              ),
              // StreamBuilder<QuerySnapshot>(
              //   stream: _firestore
              //       .collection('newGifts')
              //       .snapshots(), // Adjust the collection name if needed
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     }
              //
              //     if (!snapshot.hasData) {
              //       return Center(child: CircularProgressIndicator());
              //     }
              //
              //     final documents = snapshot.data?.docs;
              //     if (documents != null) {
              //       for (final doc in documents) {
              //         if (doc.data() != null) {
              //           if (doc.data() != null) {
              //             _showGiftDialog(doc.data());
              //           }
              //         }
              //       }
              //     }
              //
              //     return Container(); //
              //   },
              // ),
            ],
          );
        }),
      );
    });
  }

  Widget getdata(
    BoxConstraints constraints,
    GetUserExpModel UserEXPModel,
    String model1,
    InRoomUserModelModel RoomUserModelModelLoaded,
    TextEditingController texteditController,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = MediaQuery.of(context).size;
      final theme = Theme.of(context);

      return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
            top: false,
            child: WillPopScope(
              onWillPop: _closeRoom,
              child: Scaffold(
                body: Container(
                  child: Stack(
                    children: [
                      background != null
                          ? Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(widget.roomImage),
                                    fit: BoxFit.cover),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(widget.roomImage),
                                    fit: BoxFit.cover),
                              ),
                            ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40.0, horizontal: 8.0),
                        child: SizedBox(
                            child: Column(
                          children: <Widget>[
                            Flexible(
                              child: RoomTopHeaderRow(size, context,
                                  UserEXPModel, theme, texteditController),
                            ),
                            5.height,
                            RoomUserDetailsRow(theme, context),
                            16.height,
                            Container(
                              height: 70,
                              child: _roomMicsLayout(),
                            ),
                            16.height,
                            Expanded(child: buildListMessage(size)),
                          ],
                        )),
                      ),
                      RoomMessageWriteingRow(
                          context, UserEXPModel, texteditController, theme),
                      // StreamBuilder(
                      //   stream: FirebaseDatabase.instance
                      //       .ref()
                      //       .child('roomNotifications')
                      //       .child(roomID)
                      //       .onValue,
                      //   builder: (context, AsyncSnapshot snapshot) {
                      //     // Removed '<DatabaseEvent>'
                      //     if (snapshot.hasError) {
                      //       return Text('Error: ${snapshot.error}');
                      //     } else if (!snapshot.hasData) {
                      //       return CircularProgressIndicator();
                      //     } else {
                      //       final notifications = snapshot.data.snapshot.value;
                      //
                      //       if (notifications is Map) {
                      //         // Check type
                      //         notifications.forEach((key, value) async {
                      //           final giftId = value['giftId'];
                      //           final giftData = await FirebaseFirestore
                      //               .instance
                      //               .collection('gifts')
                      //               .doc(giftId)
                      //               .get();
                      //
                      //           WidgetsBinding.instance
                      //               .addPostFrameCallback((_) {
                      //             // Construct the dialog with data from 'giftData'
                      //             String senderName =
                      //                 giftData.data()['senderUserName'] ??
                      //                     'User';
                      //             String receiverName =
                      //                 giftData.data()['receiverUserName'] ??
                      //                     'User';
                      //
                      //             showDialog(
                      //               context: context,
                      //               builder: (BuildContext context) {
                      //                 Future.delayed(Duration(seconds: 10), () {
                      //                   Navigator.of(context).pop();
                      //                 });
                      //
                      //                 return AlertDialog(
                      //                   backgroundColor: Colors.transparent,
                      //                   content: Column(
                      //                     children: [
                      //                       Image.network(
                      //                           'https://onoo.online/bosh.gif'),
                      //                       Text(
                      //                           '$senderName has sent a Gift For $receiverName'),
                      //                       ElevatedButton(
                      //                         onPressed: () {
                      //                           Navigator.of(context).pop();
                      //                         },
                      //                         child: Text('Close'),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 );
                      //               },
                      //             );
                      //           });
                      //         });
                      //       }
                      //       return Container();
                      //     }
                      //   },
                      // )

                      // StreamBuilder(
                      //  if (notifications is Map) {
                      //  notifications.forEach((key, value) async {
                      //  // ... (Retrieve giftData, senderData, receiverData as before) ...
                      //
                      //  WidgetsBinding.instance.addPostFrameCallback((_) {
                      //  // Construct data for the dialog
                      //  String senderName = senderData.data()['name'] ?? 'User';
                      //  String receiverName = receiverData.data()['name'] ?? 'User';
                      //  String imageUrl = value['imageUrl'] ?? 'https://onoo.online/bosh.gif'; // Assuming you add 'imageUrl' to the notification data
                      //
                      //  showDialog(
                      //  context: context,
                      //  builder: (BuildContext context) {
                      //  Future.delayed(Duration(seconds: 5), () {
                      //  Navigator.of(context).pop();
                      //  });
                      //
                      //  return AlertDialog(
                      //  backgroundColor: Colors.transparent,
                      //  content: Column(
                      //  children: [
                      //  Image.network(imageUrl),
                      //  Text('$senderName has sent a Gift For $receiverName'),
                      //  ElevatedButton(
                      //  onPressed: () {
                      //  Navigator.of(context).pop();
                      //  },
                      //  child: Text('Close'),
                      //  ),
                      //  ],
                      //  ),
                      //  );
                      //  },
                      //  );
                      //  });
                      //  });
                      //  })
                    ],
                  ),
                ),
              ),
            )),
      );
    });
  }

  Positioned RoomMessageWriteingRow(
      BuildContext context,
      GetUserExpModel UserEXPModel,
      TextEditingController texteditController,
      ThemeData theme) {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration.collapsed(
                  hintText: "رسالتك...",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          8.width,
          // add the emoji button here
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(5.0),
              // add left margin
              margin: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.white,
              ),
            ),
            onTap: () {
              FocusScope.of(context).unfocus(); // Dismiss keyboard (optional)
              showEmojiPicker(context); // Show picker
            },
          ),

          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ).onTap(() {
            if (ismuted == true) {
              CommonFunctions.showToast('لا تملك الصلاحية', Colors.red);
            } else {
              onSendMessage(
                _messageController.text, 0,
                UserEXPModel.data.userCurrentLevel,
                // model.data.userId
              );
            }
          }),
          8.width,
          Theme(
              data: Theme.of(context).copyWith(
                dividerTheme: DividerThemeData(
                  color: Colors.white,
                ),
                cardColor: Colors.black.withOpacity(0.7),
              ),
              child: PopupMenuButton<int>(
                icon: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryLightColor,
                  ),
                  child: Icon(
                    Icons.image_rounded,
                    color: Colors.white,
                  ),
                ),
                onSelected: (item) => backgroundandpasswordselect(
                    context, item, texteditController),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                      value: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),

                          // shape: BoxShape.circle,
                        ),
                        width: 180,
                        height: 70,
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                                Text(
                                  "أغاني الغرفه",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.album,
                                  color: Colors.white,
                                ),
                                InkWell(
                                  child: Container(
                                    child: Text(
                                      "البوم الصور",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  onTap: () {
                                    imagePicker(context, theme);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                ],
              )),
          Container(
            height: 35,
            // padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryColor,
            ),
            child: IconButton(
                iconSize: 22,
                color: Colors.white,
                icon: Icon(Icons.card_giftcard_rounded),
                onPressed: () => showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return GiftScreen(roomID: widget.roomId);
                    })),
          ),
          8.width,
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black45,
              ),
              child: Icon(
                Icons.favorite_outline_outlined,
                color: Colors.blueAccent,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 350,
                      child: Scaffold(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          body: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            "مركز  الترفيه",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    height: 120,
                                    width: 80,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.games,
                                          size: 40,
                                          color: Colors.redAccent,
                                        ),
                                        // SizedBox(
                                        //   height: 20,
                                        // ),
                                        Column(
                                          children: [
                                            Text(
                                              "حجرة ورقة",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "مقص",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    height: 120,
                                    width: 80,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.monetization_on_rounded,
                                          size: 40,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "حقيبة الحظ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 120,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "عجلة الحظ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 120,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_alt_sharp,
                                          size: 40,
                                          color: kPrimaryColor,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "استطلاع الرأي",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    height: 120,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.confirmation_number_rounded,
                                          size: 40,
                                          color: kPrimaryColor,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "رقم الحظ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              )
                            ],
                          )),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  Container RoomUserDetailsRow(ThemeData theme, BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              width: 150,
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0)),
              ),
              child: InkWell(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on_rounded, color: Colors.orange),
                      SizedBox(
                        width: 6.0,
                      ),
                      Expanded(
                        child: Text(
                          widget.roomDesc,
                          maxLines: 1,
                          style: theme.textTheme.bodyText1
                              .copyWith(color: Colors.red, fontSize: 17),
                        ),
                      ),
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (builder) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                          ),
                          child: BestRoomUsers(),
                        );
                      });
                },
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: 170,
                    height: 70,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Expanded(
                            //   child: ListView.separated(
                            //     scrollDirection: Axis.horizontal,
                            //     shrinkWrap: true,
                            //     itemBuilder: (BuildContext context, int index) {
                            //       var roomUserModel =
                            //           HomeCubit.get(context).roomUserModel;
                            //       if (roomUserModel != null &&
                            //           roomUserModel.data != null) {
                            //         return UserProfileBottomSheetWidget(
                            //             roomUserModel.data[index], context);
                            //       } else {
                            //         return Container(); // return an empty container when roomUserModel or data is null
                            //       }
                            //     },
                            //     itemCount: HomeCubit.get(context)
                            //             .roomUserModel
                            //             ?.data
                            //             ?.length ??
                            //         0,
                            //     separatorBuilder:
                            //         (BuildContext context, int index) =>
                            //             SizedBox(
                            //       width: 10,
                            //     ),
                            //   ),
                            // )
                          ]),
                    ),
                  ),
                ),
                5.width,
                InkWell(
                  child: Container(
                    child: Row(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('roomUsers')
                              .doc(widget.roomId)
                              .collection('UsersInRoom')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('E');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("...");
                            }

                            // Count the number of documents in the snapshot (each document represents a user)
                            int userCount = snapshot.data.docs.length;

                            // Update the 'totalnum' variable
                            totalnum = userCount.toString();

                            return Text(
                              totalnum.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                            );
                          },
                        ),
                        Icon(Icons.person_outline, color: Colors.white),
                      ],
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(),
                        builder: (builder) {
                          print("Proday of UsersInroom Wedgit IS " +
                              widget.roomId.toString());
                          return UsersInroom(roomID: widget.roomId.toString());
                        });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void checkAndSubscribeToTopic(String roomId) {
    // Check if the roomid is subscribed to Cloud Messaging topics
    // If not subscribed, subscribe to the topic with the roomid
    FirebaseMessaging.instance.subscribeToTopic(roomId).then((value) {
      print("Subscribed to topic $roomId");
    });
  }

  Row RoomTopHeaderRow(
      Size size,
      BuildContext context,
      GetUserExpModel UserEXPModel,
      ThemeData theme,
      TextEditingController texteditController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            width: size.width / 2 - 18,
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                InkWell(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1547665979-bb809517610d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80',
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(),
                        builder: (builder) {
                          return Container(
                            color: Colors.transparent,
                            child: RoomImageTap(
                                roomDesc: widget.roomDesc,
                                totalNum: totalnum,
                                roomimage: widget.roomImage,
                                roomname: widget.roomName,
                                roomID: widget.roomId.toString(),
                                currentlevel:
                                    UserEXPModel.data.userCurrentLevel),
                          );
                        });
                  },
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomName,
                        maxLines: 1,
                        style: theme.textTheme.bodyText1
                            .copyWith(color: Colors.white, fontSize: 17),
                      ),
                      Spacer(),
                      Text(
                        "ID :${widget.roomId}",
                        maxLines: 1,
                        style: theme.textTheme.bodyText2
                            .copyWith(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                check == 0
                    // model.data.user.follow == 0
                    // model.data.user.follow == 0
                    ? IconButton(
                        onPressed: () {
                          HomeCubit.get(context).followroom(id: roomID);
                          setState(() {
                            check = 1;
                          });
                        },
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          HomeCubit.get(context).followroom(id: roomID);
                          // check = true;
                        },
                        icon: Icon(Icons.favorite, color: Color(0xFFe10deb)))
              ],
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.ios_share, color: Colors.white),
                onPressed: () {
                  // getreal();
                  print("share btn clicked");
                }),
            Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: Colors.white,
                  ),
                  cardColor: Colors.black.withOpacity(0.7),
                ),
                child: PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (item) => backgroundandpasswordselect(
                      context, item, texteditController),
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(
                              Icons.subject,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Text(
                              "الموضوعات",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )),
                    PopupMenuDivider(),
                    PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.developer_board,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Text("تطوير", style: TextStyle(color: Colors.white))
                          ],
                        )),
                    PopupMenuDivider(),
                    PopupMenuItem<int>(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Text(
                              "قفل",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )),
                    PopupMenuDivider(),
                    PopupMenuItem<int>(
                        value: 3,
                        child: Row(
                          children: [
                            Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Text(
                              "مشاركة",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )),
                  ],
                )),
            GestureDetector(
                child: Icon(Icons.close, color: Colors.white),
                //Create api for room logout
                onTap: () {
                  HomeCubit.get(context).logoutUserRoom(id: widget.roomId);
                  _closeRoom();
                })
          ],
        )
      ],
    );
  }

  Widget userprofileboshetmessageswidget(
    int index,
    DocumentSnapshot document,
    Size size,
  ) {
    if (document != null) {
      // Right (my message)
      return document.get('type') == 0
          // Text
          ? Container(
              width: size.width * 0.7,
              padding: const EdgeInsets.all(6.0),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Container(
                            width: 36,
                            height: 36,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                              child: Image.asset(
                                kDefaultProfileImage,
                                width: 36,
                                height: 36,
                              ),
                            ),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    document.get('userType') == 'owner'
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.black,
                                          )
                                        : Container(),
                                    document.get('userType') == 'user'
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.blue,
                                          )
                                        : Container(),
                                    document.get('userType') == 'supervisor'
                                        ? Icon(
                                            Icons.person,
                                            color: kPrimaryLightColor,
                                          )
                                        : Container(),
                                    document.get('packageColor') == null
                                        ? Container(
                                            child: Text(
                                              document.get('username'),
                                              style: TextStyle(
                                                  color: kPrimaryColor,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            color: Colors.transparent,
                                          )
                                        : Container(
                                            child: Text(
                                              document.get('username'),
                                              style: TextStyle(
                                                  color: HexColor(document
                                                      .get('packageColor')),
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            color: Colors.transparent,
                                          ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    document.get('hasSpecialID') == true
                                        ? Container(
                                            height: 18,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.amber,
                                                )),
                                            child: Center(
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.amber,
                                                size: 12,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    document.get('packageBadge') != null
                                        ? Container(
                                            height: 25,
                                            width: 25,
                                            child: Center(
                                                child: Image.network(document
                                                    .get('packageBadge'))),
                                          )
                                        : Container(),
                                    Container(
                                      height: 18,
                                      width: 20,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.amber,
                                          )),
                                      child: Center(
                                        child: Icon(
                                          Icons.home,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                //#Start#// Firebase message Content Display  //#Start#//
                                /* Row Name : Firebase_Message_Row*/
                                Row(children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16.0)),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 15.0, right: 5.0),
                                        child: Text(
                                          document.get('content'),
                                          style: secondaryTextStyle(
                                              color: Colors.white),
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                //E// Row Name : Firebase_Message_Row //E//
                                //#END#// Firebase message Content Display  //#END#//
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tap on the user name to view the user profile
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent, // <-- SEE HERE

                      isScrollControlled: true,
                      builder: (context) {
                        DocumentReference docRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(userid)
                            .collection('friends')
                            .doc(document.get('idFrom'));
                        docRef.get().then((DocumentSnapshot documentSnapshot) {
                          if (documentSnapshot.exists) {
                            print('Document exists on the database');
                            print(documentSnapshot.get('isFriend'));
                            isfriendfirebase = documentSnapshot.get('isFriend');
                          } else {
                            isfriendfirebase = false;
                          }
                        });

                        return FractionallySizedBox(
                          heightFactor: 0.5,
                          child: Stack(children: [
                            Column(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: new Container(
                                    height: 25,
                                    color: Colors.transparent.withOpacity(0.0),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Container(
                                    height: 290,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30)),
                                    ),
                                    // color: Colors.amber,

                                    child: Expanded(
                                      child: Column(
                                        children: [
                                          SingleChildScrollView(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 12),
                                                  child: Container(
                                                    height: 22,
                                                    width: 25,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.orange,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "@",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20, top: 12),
                                                  child: Container(
                                                    height: 22,
                                                    width: 25,
                                                    child: Icon(
                                                      Icons
                                                          .report_problem_outlined,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(document.get('username')),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Get the usertype to write his type in room for his bottomsheet profile
                                              if (document.get('userType') ==
                                                  'user')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: kPrimaryColor,
                                                          style:
                                                              BorderStyle.solid,
                                                        ),
                                                        // shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        'عضو',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ))),
                                                ),
                                              if (document.get('userType') ==
                                                  'supervisor')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: kPrimaryColor,
                                                          style:
                                                              BorderStyle.solid,
                                                        ),
                                                        // shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        'مشرف',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ))),
                                                ),
                                              if (document.get('userType') ==
                                                  'owner')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: kPrimaryColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: kPrimaryColor,
                                                          style:
                                                              BorderStyle.solid,
                                                        ),
                                                        // shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        'مالك',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ))),
                                                ),
                                              SizedBox(
                                                width: 10,
                                              ),

                                              // write user id under his name in the bottomsheet profile
                                              Text(
                                                'ID:${document.get('specialId').toString()}',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),

                                              // write user Level under his name in the bottomsheet profile
                                              Text(
                                                'LV ${document.get('userLevel').toString()}',
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                width: 30,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 18,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                    border: Border.all(
                                                      width: 2,
                                                      color: Colors.amber,
                                                    )),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.amber,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 18,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                    border: Border.all(
                                                      width: 2,
                                                      color: Colors.amber,
                                                    )),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.markunread_mailbox,
                                                    color: Colors.amber,
                                                    size: 10,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 18,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                    border: Border.all(
                                                      width: 2,
                                                      color: Colors.amber,
                                                    )),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.home,
                                                    color: Colors.amber,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // if (isfriendfirebase == true)
                                                isfriendfirebase == true
                                                    ? Column(
                                                        children: [
                                                          MaterialButton(
                                                            onPressed: () {},
                                                            color:
                                                                Colors.yellow,
                                                            textColor:
                                                                Colors.white,
                                                            child: Icon(
                                                              Icons
                                                                  .message_rounded,
                                                              size: 14,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                            shape:
                                                                CircleBorder(),
                                                          ),
                                                          Text(
                                                            "الرسائل",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          )
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          MaterialButton(
                                                            onPressed: () {},
                                                            color:
                                                                Colors.yellow,
                                                            textColor:
                                                                Colors.white,
                                                            child: Icon(
                                                              Icons.person_add,
                                                              size: 14,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                            shape:
                                                                CircleBorder(),
                                                          ),
                                                          Text(
                                                            'إضافه صديق',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          )
                                                        ],
                                                      ),
                                                Column(
                                                  children: [
                                                    MaterialButton(
                                                      onPressed: () {},
                                                      color: kPrimaryLightColor,
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons
                                                            .mic_external_off_rounded,
                                                        size: 14,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      shape: CircleBorder(),
                                                    ),
                                                    Text(
                                                      'كتم الصوت',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    MaterialButton(
                                                      onPressed: () {
                                                        //     Get.to(StackDemo());
                                                      },
                                                      color: Colors.red,
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons.star,
                                                        size: 14,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      shape: CircleBorder(),
                                                    ),
                                                    Text(
                                                      'البطاقات السحرية',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    MaterialButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);

                                                        showModalBottomSheet(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return GiftScreen(
                                                                  roomID:
                                                                      roomID,
                                                                  userID: document
                                                                      .get(
                                                                          'ApiUserID'),
                                                                  check: true,
                                                                  username: document
                                                                      .get('username'
                                                                          .toString()) // userID: model.userId
                                                                  // .toString(),
                                                                  );
                                                            });
                                                      },
                                                      color: Colors.blueAccent,
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons.card_giftcard,
                                                        size: 14,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      shape: CircleBorder(),
                                                    ),
                                                    Text(
                                                      'إرسال هديه',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(
                                                            width: 1.0,
                                                            color: Colors
                                                                .grey.shade300),
                                                        bottom: BorderSide(
                                                            width: 1.0,
                                                            color: Colors
                                                                .lightBlue
                                                                .shade900),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              showDialog<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(15))),
                                                                    title:
                                                                        Center(
                                                                      child: const Text(
                                                                          'هل تريد حظر العضو'),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              HomeCubit.get(context).addBlockList(id: document.get('ApiUserID'));
                                                                              Navigator.pop(context, 'yes');

                                                                              CommonFunctions.showToast('تم حظر العضو', Colors.green);
                                                                            },
                                                                            child:
                                                                                const Text('نعم'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context, 'no'),
                                                                            child:
                                                                                const Text('لا'),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                              // print(model.userId);
                                                            },
                                                            icon: Icon(
                                                              Icons.logout,
                                                              color: Colors.grey
                                                                  .shade400,
                                                              size: 25,
                                                            )),
                                                        VerticalDivider(),
                                                        IconButton(
                                                            onPressed: () {
                                                              showDialog<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(15))),
                                                                    title:
                                                                        Center(
                                                                      child: const Text(
                                                                          'هل تريد اصمات العضو'),
                                                                    ),
                                                                    // content: const Text('AlertDialog description'),
                                                                    actions: <
                                                                        Widget>[
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              ismuted = true;
                                                                              _updateuserDataFirebase(roomID, document.get('username'), document.get('idFrom'));

                                                                              _updateMutedFirebase(
                                                                                roomID,
                                                                              );

                                                                              Navigator.pop(context, 'yes');

                                                                              CommonFunctions.showToast('تم اصمات العضو', Colors.green);
                                                                            },
                                                                            child:
                                                                                const Text('نعم'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context, 'no'),
                                                                            child:
                                                                                const Text('لا'),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .block_rounded,
                                                              color: Colors.grey
                                                                  .shade400,
                                                              size: 25,
                                                            )),
                                                        VerticalDivider(),
                                                        IconButton(
                                                            onPressed: () {},
                                                            icon: Icon(
                                                              Icons.mic,
                                                              color: Colors.grey
                                                                  .shade400,
                                                              size: 25,
                                                            )),
                                                        VerticalDivider(),
                                                        Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                              dividerTheme:
                                                                  DividerThemeData(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              cardColor: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.7),
                                                            ),
                                                            child:
                                                                PopupMenuButton<
                                                                    int>(
                                                              icon: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .green,
                                                                size: 25,
                                                              ),
                                                              onSelected: (item) =>
                                                                  supervrormanagmentselect(
                                                                      context,
                                                                      item,
                                                                      document.get(
                                                                          'ApiUserID'),
                                                                      roomID),
                                                              itemBuilder:
                                                                  (context) => [
                                                                PopupMenuItem<
                                                                        int>(
                                                                    value: 0,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            "تعين مشرف",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )),
                                                                PopupMenuDivider(),
                                                                PopupMenuItem<
                                                                        int>(
                                                                    value: 1,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Center(
                                                                          child: Text(
                                                                              "تعين عضو",
                                                                              style: TextStyle(color: Colors.white)),
                                                                        )
                                                                      ],
                                                                    )),
                                                                PopupMenuDivider(),
                                                                PopupMenuItem<
                                                                        int>(
                                                                    value: 2,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "ازالة العضو",
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        )
                                                                      ],
                                                                    )),
                                                              ],
                                                            )),
                                                      ],
                                                    )),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              // height: 70,

                              alignment: Alignment.topCenter,
                              child: FloatingActionButton(
                                onPressed: () {},
                                child: CircleAvatar(
                                  child: Image.asset(
                                      "assets/images/Profile Image.png"),
                                  backgroundColor: kPrimaryColor,
                                  radius: 50,
                                ),
                              ),
                            ),
                          ]),
                        );
                      });
                },
              ),
            )
          : document.get('type') == 1
              // Image
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        width: 36,
                        height: 36,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          child: Image.asset(
                            kDefaultProfileImage,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            document.get('userType') == 'owner'
                                ? Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  )
                                : Container(),
                            document.get('userType') == 'user'
                                ? Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  )
                                : Container(),
                            document.get('userType') == 'supervisor'
                                ? Icon(
                                    Icons.person,
                                    color: kPrimaryLightColor,
                                  )
                                : Container(),
                            document.get('packageColor') == null
                                ? Container(
                                    child: Text(
                                      document.get('username'),
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                    color: Colors.transparent,
                                  )
                                : Container(
                                    child: Text(
                                      document.get('username'),
                                      style: TextStyle(
                                          color: HexColor(
                                              document.get('packageColor')),
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                    color: Colors.transparent,
                                  ),
                            SizedBox(
                              width: 5,
                            ),
                            document.get('hasSpecialID') == true
                                ? Container(
                                    height: 18,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.amber,
                                        )),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.amber,
                                        size: 12,
                                      ),
                                    ),
                                  )
                                : Container(),
                            document.get('packageBadge') != null
                                ? Container(
                                    height: 25,
                                    width: 25,
                                    child: Center(
                                        child: Image.network(
                                            document.get('packageBadge'))),
                                  )
                                : Container(),
                            Container(
                              height: 18,
                              width: 20,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.amber,
                                  )),
                              child: Center(
                                child: Icon(
                                  Icons.home,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: OutlinedButton(
                              child: Material(
                                child: Image.network(
                                  document.get("content"),
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade600,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {},
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(0))),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )

              // Sticker
              : Container(
                  child: Image.asset(
                    'images/${document.get('content')}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                );
    } else {
      return SizedBox.shrink();
    }
  }

  /// This widget is responsible for building a list of messages in the room.
  ///
  /// It fetches the messages from Firestore and displays them in a ListView.
  /// If there are no messages available, it displays a loading indicator.
  ///
  /// The widget is expanded to take up 3 flex space of its parent Flex widget.
  ///
  /// Returns:
  /// A widget that either shows the messages in the room or a loading indicator.
  Widget buildListMessage(Size size) {
    // The widget is expanded to take up 3 flex space of its parent Flex widget
    return Expanded(
      flex: 3,
      // StreamBuilder is used to build the UI based on the stream data
      child: StreamBuilder<QuerySnapshot>(
        // The stream is the collection of messages in the room, ordered by timestamp in descending order
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.roomId.toString())
            .collection(widget.roomId.toString())
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .snapshots(),
        // The builder takes the current context and snapshot of the stream
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // If the snapshot has data, add the documents in the snapshot to the list of messages
          if (snapshot.hasData) {
            listMessage.addAll(snapshot.data.docs);
            // Return a ListView.builder to build the list of messages
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => userprofileboshetmessageswidget(
                index,
                snapshot.data?.docs[index],
                size,
              ),
              itemCount: snapshot.data?.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            // If the snapshot does not have data, display a loading indicator
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            );
          }
        },
      ),
    );
  }

  /// A generic StreamTransformer that transforms a Stream of QuerySnapshots into a Stream of Lists.
  ///
  /// This StreamTransformer takes a function that converts a Map<String, dynamic> into an object of type T.
  /// It applies this function to each document in the QuerySnapshot to convert it into an object of type T.
  /// It then emits a List of these objects.
  ///
  /// The StreamTransformer is generic over the type T.
  ///
  /// Parameters:
  /// - [fromJson]: A function that converts a Map<String, dynamic> into an object of type T.
  ///
  /// Returns:
  /// - A StreamTransformer that transforms a Stream of QuerySnapshots into a Stream of Lists of objects of type T.
  static StreamTransformer transformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          List<T>>.fromHandlers(
        handleData: (QuerySnapshot<Map<String, dynamic>> data,
            EventSink<List<T>> sink) {
          // Convert each document in the QuerySnapshot into a Map<String, dynamic>
          final snaps = data.docs.map((doc) => doc.data()).toList();
          // Convert each Map<String, dynamic> into an object of type T using the provided function
          final users = snaps.map((json) => fromJson(json)).toList();

          // Emit the List of objects of type T
          sink.add(users);
        },
      );

  /// This widget is responsible for displaying the layout of microphones in a room.
  /// It fetches the data of the microphones from Firestore and displays them in a grid layout.
  /// If there is no data available, it displays a default layout with empty microphones.
  Widget _roomMicsLayout() {
    // Create a stream of UserMicModel objects by transforming the Firestore snapshot
    Stream<List<UserMicModel>> _stream = _firestoreInstance
        .collection('roomUsers')
        .doc(widget.roomId)
        .collection('roommics')
        .snapshots()
        .transform(
            transformer<UserMicModel>((json) => UserMicModel.fromJson(json)));

    // Use a StreamBuilder to build the UI based on the stream data
    return StreamBuilder<List<UserMicModel>>(
        stream: _stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<UserMicModel>> snapshot) {
          // If the snapshot has data and it's not empty
          if (snapshot.hasData && snapshot.data.length > 0) {
            // Update the list of microphone users
            _micUsersList = snapshot.data;

            // Return a column of two rows, each containing 5 microphone users
            return Column(children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return Flexible(
                      child: RoomMicsWidget(
                        index,
                        snapshot.data[index],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return RoomMicsWidget(
                      index + 5,
                      snapshot.data[index + 5],
                    );
                  }).toList(),
                ),
              ),
            ]);
          } else {
            // If the snapshot doesn't have data, display a default layout with empty microphones
            List<UserMicModel> _micsList = [];

            // Generate 10 empty microphones
            for (int i = 0; i < 10; i++) {
              _micsList.add(UserMicModel(
                  id: null,
                  userId: null,
                  userName: null,
                  micNumber: i,
                  micStatus: false,
                  isLocked: false));
            }

            // Return a row of 10 empty microphones
            return Expanded(
              child: Row(
                children: List.generate(10, (index) {
                  return RoomMicsWidget(
                    index,
                    _micsList[index],
                  );
                }).toList(),
              ),
            );
          }
        });
  }

  /// This widget represents an individual item in the room.
  ///
  /// It displays the user's avatar, name, and other details. When tapped, it opens a bottom sheet with more options.
  ///
  /// Parameters:
  /// - [model]: An instance of [InRoomUserModelModelData] containing the user's information.
  /// - [context]: The build context in which this widget is being constructed.
  ///
  /// Returns:
  /// - An [InkWell] widget that responds to touch events.
  Widget UserProfileBottomSheetWidget(
          InRoomUserModelModelData model, BuildContext context) =>
      InkWell(
        // This widget represents a user in the room.
//
// It is a Padding widget that contains a Column widget. The Column widget
// aligns its children along the vertical axis in the center.
//
// The children of the Column widget are:
// 1. A Padding widget that contains a CircleAvatar widget. The CircleAvatar
//    widget displays the user's profile image. The image is loaded from the
//    assets directory.
// 2. A SizedBox widget that serves as a vertical spacer.
// 3. A Text widget that displays the user's name. The text color is white and
//    the font size is 10.
// 4. A Spacer widget that takes up any remaining space along the main axis.
//
// When this widget is tapped, it opens a bottom sheet with more options.
        child: Padding(
          // Add padding to the top of the widget
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            // Align the children along the vertical axis in the center
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                // Add padding to all sides of the widget
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  // Set the radius of the CircleAvatar
                  radius: 18,
                  // Load the user's profile image from the assets directory
                  backgroundImage: AssetImage(
                    "assets/images/Profile Image.png",
                  ),
                ),
              ),
              // Add a vertical spacer
              SizedBox(
                height: 2,
              ),
              // Display the user's name
              Text(
                model.name.toString(),
                // Set the text color to white and the font size to 10
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              // Take up any remaining space along the main axis
              Spacer(),
            ],
          ),
        ),
        onTap: () {
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.42,
                  child: Stack(children: [
                    Column(
                      children: [
                        new Container(
                          height: 30,
                          color: Colors.transparent.withOpacity(0.0),
                        ),
                        Expanded(
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 12),
                                        child: Container(
                                          height: 22,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.orange,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "@",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 12),
                                        child: Container(
                                          height: 22,
                                          width: 25,
                                          child: Icon(
                                            Icons.report_problem_outlined,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(model.name.toString()),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(text),
                                      if (model.typeUser == 'user')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                  width: 1,
                                                  color: kPrimaryColor,
                                                  style: BorderStyle.solid,
                                                ),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                  child: Text(
                                                'عضو',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ))),
                                        ),
                                      if (model.typeUser == 'supervisor')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                  width: 1,
                                                  color: kPrimaryColor,
                                                  style: BorderStyle.solid,
                                                ),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                  child: Text(
                                                'مشرف',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ))),
                                        ),
                                      if (model.typeUser == 'owner')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                  width: 1,
                                                  color: kPrimaryColor,
                                                  style: BorderStyle.solid,
                                                ),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                  child: Text(
                                                'مالك',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ))),
                                        ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'ID:${model.spacialId}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "LV ${model.level[0].userCurrentLevel.toString()}",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 18,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.amber,
                                            )),
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.amber,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 18,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.amber,
                                            )),
                                        child: Center(
                                          child: Icon(
                                            Icons.markunread_mailbox,
                                            color: Colors.amber,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 18,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.amber,
                                            )),
                                        child: Center(
                                          child: Icon(
                                            Icons.home,
                                            color: Colors.amber,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (model.isFriend == true)
                                        Column(
                                          children: [
                                            MaterialButton(
                                              onPressed: () {
                                                Get.to(Onechat(
                                                  user: model,
                                                  fromRoomUser: true,
                                                ));
                                              },
                                              color: Colors.yellow,
                                              textColor: Colors.white,
                                              child: Icon(
                                                Icons.message_rounded,
                                                size: 14,
                                              ),
                                              padding: EdgeInsets.all(16),
                                              shape: CircleBorder(),
                                            ),
                                            Text(
                                              "الرسائل",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      if (model.isFriend == false)
                                        Column(
                                          children: [
                                            MaterialButton(
                                              onPressed: () {
                                                HomeCubit.get(context)
                                                    .addfriend(
                                                  id: model.userId,
                                                );

                                                // print(HomeCubit.get(context)
                                                //     .addfriendsModel
                                                //     .message);
                                              },
                                              color: Colors.yellow,
                                              textColor: Colors.white,
                                              child: Icon(
                                                Icons.person_add,
                                                size: 14,
                                              ),
                                              padding: EdgeInsets.all(16),
                                              shape: CircleBorder(),
                                            ),
                                            Text(
                                              'إضافه صديق',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      Column(
                                        children: [
                                          MaterialButton(
                                            onPressed: () {},
                                            color: kPrimaryLightColor,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.mic_external_off_rounded,
                                              size: 14,
                                            ),
                                            padding: EdgeInsets.all(16),
                                            shape: CircleBorder(),
                                          ),
                                          Text(
                                            'كتم الصوت',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MaterialButton(
                                            onPressed: () {
                                              // Get.to(StackDemo());
                                            },
                                            color: Colors.pink,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.star,
                                              size: 14,
                                            ),
                                            padding: EdgeInsets.all(16),
                                            shape: CircleBorder(),
                                          ),
                                          Text(
                                            'البطاقات السحرية',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);

                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return GiftScreen(
                                                      roomID: roomID,
                                                      userID: model.userId
                                                          .toString(),
                                                      check: true,
                                                      username: model.name,
                                                      // userID: model.userId
                                                      // .toString(),
                                                    );
                                                  });
                                            },
                                            color: Colors.blueAccent,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.card_giftcard,
                                              size: 14,
                                            ),
                                            padding: EdgeInsets.all(16),
                                            shape: CircleBorder(),
                                          ),
                                          Text(
                                            'إرسال هديه',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    width: 1.0,
                                                    color:
                                                        Colors.grey.shade300),
                                                bottom: BorderSide(
                                                    width: 1.0,
                                                    color: Colors
                                                        .lightBlue.shade900),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child: AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15))),
                                                            title: Center(
                                                              child: const Text(
                                                                  'هل تريد حظر العضو'),
                                                            ),
                                                            // content: const Text('AlertDialog description'),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      HomeCubit.get(
                                                                              context)
                                                                          .addBlockList(
                                                                              id: model.userId);
                                                                      Navigator.pop(
                                                                          context,
                                                                          'yes');

                                                                      CommonFunctions.showToast(
                                                                          'تم حظر العضو',
                                                                          Colors
                                                                              .green);
                                                                    },
                                                                    child: const Text(
                                                                        'نعم'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'no'),
                                                                    child:
                                                                        const Text(
                                                                            'لا'),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.logout,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 25,
                                                    )),
                                                VerticalDivider(),
                                                IconButton(
                                                    onPressed: () {
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child: AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15))),
                                                            title: Center(
                                                              child: const Text(
                                                                  'هل تريد اصمات العضو'),
                                                            ),
                                                            // content: const Text('AlertDialog description'),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      ismuted =
                                                                          true;
                                                                      _updateuserDataFirebase(
                                                                          roomID,
                                                                          model
                                                                              .name,
                                                                          model
                                                                              .spacialId);

                                                                      _updateMutedFirebase(
                                                                        roomID,
                                                                      );

                                                                      Navigator.pop(
                                                                          context,
                                                                          'yes');
                                                                    },
                                                                    child: const Text(
                                                                        'نعم'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'no'),
                                                                    child:
                                                                        const Text(
                                                                            'لا'),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.block_rounded,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 25,
                                                    )),
                                                VerticalDivider(),
                                                IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                      Icons.mic,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 25,
                                                    )),
                                                VerticalDivider(),
                                                Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      dividerTheme:
                                                          DividerThemeData(
                                                        color: Colors.white,
                                                      ),
                                                      cardColor: Colors.black
                                                          .withOpacity(0.7),
                                                    ),
                                                    child: PopupMenuButton<int>(
                                                      icon: Icon(
                                                        Icons.person,
                                                        color: Colors.green,
                                                        size: 25,
                                                      ),
                                                      onSelected: (item) =>
                                                          supervrormanagmentselect(
                                                              context,
                                                              item,
                                                              model.userId,
                                                              roomID),
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem<int>(
                                                            value: 0,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    "تعين مشرف",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )
                                                              ],
                                                            )),
                                                        PopupMenuDivider(),
                                                        PopupMenuItem<int>(
                                                            value: 1,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                      "تعين عضو",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )
                                                              ],
                                                            )),
                                                        PopupMenuDivider(),
                                                        PopupMenuItem<int>(
                                                            value: 2,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "ازالة العضو",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              ],
                                                            )),
                                                      ],
                                                    )),
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      // height: 70,

                      alignment: Alignment.topCenter,

                      child: FloatingActionButton(
                        onPressed: () {},
                        child: CircleAvatar(
                          child: Image.asset("assets/images/Profile Image.png"),
                          backgroundColor: kPrimaryColor,
                          radius: 50,
                        ),
                      ),
                    ),
                  ]),
                );
              });
        },
      );

  /// Updates or creates a user document in Firebase.
  ///
  /// This function is used to update a user's document in a Firebase collection.
  /// If the document does not exist, it creates a new one.
  ///
  /// The collection is structured as follows: 'roomUsers' -> roomID -> 'UsersInRoom'.
  /// Each document in the 'UsersInRoom' sub-collection represents a user in the room.
  ///
  /// Parameters:
  /// - [id]: The user's ID. This is used as the document ID in the collection.
  /// - [name]: The user's name.
  /// - [roomID]: The ID of the room the user is in.
  ///
  /// This function performs the following steps:
  /// 1. Retrieves a reference to the appropriate Firebase collection.
  /// 2. Checks if the user's document exists in the collection.
  /// 3. If the document exists, it updates the document with the new user information.
  /// 4. If the document does not exist, it creates a new document with the user information.
  ///
  /// This function is asynchronous and returns a [Future] that completes when the update or creation operation is finished.
  void _updateuserDataFirebase(String id, String name, String roomID) async {
    // Get a reference to the Firebase collection
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('roomUsers')
        .doc(roomID)
        .collection('UsersInRoom');

    // Get a reference to the user's document in the collection
    DocumentReference documentReference = _collectionRef.doc(id);

    // Check if the user's document exists in the collection
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      // If the user's document exists, update it with the new user information
      await documentReference.update(
          {'username': name, 'userID': id, 'roomId': roomID, 'state': ismuted});
    } else {
      // If the user's document does not exist, create a new document with the user information
      await documentReference.set(
          {'username': name, 'userID': id, 'roomId': roomID, 'state': ismuted});
    }
  }

  void _addMicsToFirebase(String roomId) async {
    try {
      // Factory method to create mic models
      UserMicModel createMicModel(
          {int micNumber, bool isLocked = false, bool micStatus = false}) {
        return UserMicModel(
            id: null,
            userId: null,
            micNumber: micNumber,
            isLocked: isLocked,
            micStatus: micStatus);
      }

      final mics = <UserMicModel>[];

      // Generate mic models in a loop
      for (int i = 0; i < 10; i++) {
        mics.add(createMicModel(micNumber: i));
      }

      // Get a reference to the Firestore collection where the mics will be stored
      CollectionReference _collectionRef = FirebaseFirestore.instance
          .collection('roomUsers')
          .doc(roomId)
          .collection('roommics');

      // Check if the mics already exist
      QuerySnapshot querySnapshot = await _collectionRef.get();
      if (querySnapshot.docs.isEmpty) {
        // If the mics do not exist, write all models in a batch
        final batch = FirebaseFirestore.instance.batch();

        mics.forEach((mic) {
          batch.set(_collectionRef.doc('mic${mic.micNumber}'), mic.toJson());
        });

        // Commit the batch to write all the mics to Firestore
        await batch.commit();
      }
    } catch (e) {
      // If any error occurs during the execution of the code, it is caught here
      print('Error occurred in _addMicsToFirebase: $e');
    }
  }

  void _updateMutedFirebase(String roomID) async {
    // print("inUpdate doc: $index");
    // print("name: ${micModel.userName}");
    // print("id: ${micModel.userId}");
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('roomUsers')
        .doc(roomID)
        .collection(roomID);
    await _collectionRef.doc("0").update({
      "id": null,
      "userId": null,
      "userName": null,
      "micNumber": null,
      "micStatus": false,
      "isLocked": false
    }).catchError((e) {
      print(e);
      return;
    });
  }

  /// Updates the microphone status of a user in a Firebase collection.
  ///
  /// This function is used to update the microphone status of a user in a Firebase collection.
  /// The collection is structured as follows: 'roomUsers' -> roomID -> roomID.
  /// Each document in the innermost collection represents a user's microphone status in the room.
  ///
  /// Parameters:
  /// - [index]: The index of the user in the room. This is used as the document ID in the collection.
  /// - [micModel]: A [UserMicModel] instance containing the user's microphone status information.
  ///
  /// This function performs the following steps:
  /// 1. Prints the index and user information for debugging purposes.
  /// 2. Retrieves a reference to the appropriate Firebase collection.
  /// 3. Attempts to update the document corresponding to the user in the collection with the new microphone status.
  /// 4. If an error occurs during the update, it is caught and printed to the console.
  ///
  /// This function is asynchronous and returns a [Future] that completes when the update operation is finished.
  void _updateMicsToFirebase(int index, UserMicModel micModel) async {
    // Debugging prints
    print("inUpdate doc: $index");
    print("name: ${micModel.userName}");
    print("id: ${micModel.userId}");

    // Get a reference to the Firebase collection
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('roomUsers')
        .doc(roomID)
        .collection('roommics');

    // Attempt to update the document in the collection
    await _collectionRef.doc("$index").update({
      "id": micModel.id,
      "userId": micModel.userId,
      "userName": micModel.userName,
      "micNumber": micModel.micNumber,
      "micStatus": micModel.micStatus,
      "isLocked": micModel.isLocked
    }).catchError((e) {
      // Print any errors that occur during the update
      print(e);
      return;
    });
  }

  Future<void> countUsersInRoomAndUpdate() async {
    try {
      // Get a reference to the 'UsersInRoom' collection in Firestore
      CollectionReference usersInRoomRef = FirebaseFirestore.instance
          .collection('roomUsers')
          .doc(widget.roomId)
          .collection('UsersInRoom');

      // Get a snapshot of the 'UsersInRoom' collection
      QuerySnapshot snapshot = await usersInRoomRef.get();

      // Count the number of documents in the snapshot (each document represents a user)
      int userCount = snapshot.docs.length;

      // Update the 'totalnum' variable
      totalnum = userCount.toString();

      print(
          "countUsersInRoomAndUpdate() has been completed. Total number of users in room is " +
              totalnum);
    } catch (e) {
      print("Error in countUsersInRoomAndUpdate(): " + e.toString());
    }
  }

  //// Get rooms Collection , Usernow filed in roomid doc to return string value for totalnum variable
  //// By Hedra Adel
  // void GetRoomsCollection() async {
  //   try {
  //     await for (var snapshot in _firestoreInstance
  //         .collection('rooms')
  //         .doc(widget.roomId)
  //         .snapshots()) {
  //       var messeage = snapshot.get('userNow');
  //
  //       print("GetRoomsCollection() Has been Complete and message content is " +
  //           messeage.toString() +
  //           "--- Hedra Adel ---");
  //
  //       totalnum = messeage.toString();
  //     }
  //   } catch (e) {
  //     print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  //     print(" - Error - There is Error in ${hedra.fileName} -- " +
  //         "In Line : ${hedra.lineNumber} -- " +
  //         "The caller function : ${hedra.callerFunctionName} -- " +
  //         "The Details is : :::: " +
  //         e.toString() +
  //         " :::: " +
  //         "-- Hedra Adel - Error -");
  //     print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  //   }
  // }

  void onUserLogout(String userId, String roomId) {
    // Remove the user from the backend API
    // OnlineRoomListBackend().removeOnlineUser(userId, roomId);

    // Remove the user from Firebase
    FirebaseFirestore.instance
        .collection('UsersInRoom')
        .doc(roomId)
        .collection(roomId)
        .doc(userId)
        .delete();

    // ... other logic for when the user logs out
  }

  //// Get the Muted users in the Users in room(UsersInRoom) From firestore
  //// By Hedra Adel
  void isUserMuted() async {
    final firestoreInstance = FirebaseFirestore.instance;

    // Check if the user document exists in the 'MutedList' sub-collection
    DocumentSnapshot mutedListDoc = await firestoreInstance
        .collection('roomUsers')
        .doc(widget.roomId)
        .collection(
            'MutedList') // Assuming 'MutedList' is the sub-collection you want to access
        .doc(widget.userID) // Provide the user's ID to the .doc() method
        .get();

    // Check if the 'ismuted' field exists in the 'FollowersUsers' sub-collection
    DocumentSnapshot followersUsersDoc = await firestoreInstance
        .collection('roomUsers')
        .doc(widget.roomId)
        .collection('FollowersUsers')
        .doc(widget.userID)
        .get();

    if (followersUsersDoc.exists &&
            followersUsersDoc.data() != null &&
            (followersUsersDoc.data() as Map<String, dynamic>)['ismuted'] ==
                true ||
        mutedListDoc.exists) {
      ismuted = true;
    } else {
      ismuted = false;
    }
  }

  Future<bool> _closeRoom() async {
    await CommonFunctions.showAlertWithTwoActions(
        widget.roomId, context, "خروج", "هل تريد الخروج من الغرفة؟", () async {
      {
        finish(context);
      }

      finish(
        context,
      );
    });
    return true;
  }

  /// Executes an action based on the selected item in a menu.
  ///
  /// This function is used to perform an action based on the user's selection in a menu.
  /// The menu items are represented by an integer index, and each index corresponds to a different action.
  ///
  /// Parameters:
  /// - [context]: The build context in which the function is being called.
  /// - [item]: The index of the selected item in the menu.
  /// - [userID]: The ID of the user performing the action.
  /// - [roomid]: The ID of the room in which the action is being performed.
  ///
  /// This function performs the following actions based on the selected item:
  /// - 0: Calls the `postSupervsorroom` method of the `HomeCubit` class, passing the user's ID as an argument.
  /// - 1: Calls the `deleteSupervsorroom` method of the `HomeCubit` class, passing the user's ID as an argument.
  /// - 2: Calls the `postUnfollowser` method of the `HomeCubit` class, passing the user's ID and the room ID as arguments.
  void supervrormanagmentselect(
      BuildContext context, int item, int userID, String roomid) {
    switch (item) {
      case 0:
        HomeCubit.get(context).postSupervsorroom(id: userID);
        break;

      case 1:
        HomeCubit.get(context).deleteSupervsorroom(id: userID);
        break;

      case 2:
        HomeCubit.get(context).postUnfollowser(idUser: userID, idRoom: roomid);
        break;
    }
  }

  // void onSelected2(
  //     //   BuildContext context,
  //     int item,
  //     String userID,
  //     String roomid) {
  //   switch (item) {
  //     case 0:
  //       HomeCubit.get(context).postSupervsorroom(id: userID);
  //       // Navigator.of(context).push(
  //       //     MaterialPageRoute(builder: (context) => ShopbackgroundGift()));
  //       break;
  //
  //     case 1:
  //       HomeCubit.get(context).deleteSupervsorroom(id: userID);
  //       // Navigator.of(context).push(
  //       //     MaterialPageRoute(builder: (context) => ShopbackgroundGift()));
  //       break;
  //
  //     case 2:
  //       HomeCubit.get(context).postUnfollowser(idUser: userID, idRoom: roomid);
  //       // Navigator.of(context).push(
  //       //     MaterialPageRoute(builder: (context) => ShopbackgroundGift()));
  //       break;
  //   }
  // }

  /// Executes an action based on the selected item in a menu.
  ///
  /// This function is used to perform an action based on the user's selection in a menu.
  /// The menu items are represented by an integer index, and each index corresponds to a different action.
  ///
  /// Parameters:
  /// - [context]: The build context in which the function is being called.
  /// - [item]: The index of the selected item in the menu.
  /// - [_controller]: The TextEditingController for the password input field.
  ///
  /// This function performs the following actions based on the selected item:
  /// - 0: Navigates to the ShopbackgroundGift screen, passing the room ID as an argument.
  /// - 2: If the user is the owner of the room, it shows a dialog for the user to set a password for the room.
  void backgroundandpasswordselect(
      BuildContext context, int item, TextEditingController _controller) {
    switch (item) {
      case 0:
        // Print the room ID for debugging purposes
        print('Room ID: $roomID');
        // Navigate to the ShopbackgroundGift screen, passing the room ID as an argument
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShopbackgroundGift(roomId_get: roomID)));
        break;

      case 2:
        // If the user is the owner of the room, show a dialog for setting a password
        if (userstateInroom == 'owner') {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                title: Center(
                  child: const Text('برجاء تعين كلمة المرور للغرفة'),
                ),
                // content: const Text('AlertDialog description'),
                actions: <Widget>[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: CommonFunctions().nbAppTextFieldWidget(
                                _controller,
                                'Password',
                                "ادخل كلمة المرور",
                                'برجاء ادخال كلمه المرور',
                                TextFieldType.PASSWORD,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Set the room password using the HomeCubit
                                HomeCubit.get(context).setRoomPassword(
                                    roompassword: _controller.text);

                                // Close the dialog
                                Navigator.pop(context, 'yes');

                                // Show a toast message indicating that the password has been set
                                CommonFunctions.showToast(
                                    'تم تعين كلمة مرور للغرفة ', Colors.green);
                              },
                              child: const Text(
                                'تعين',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          // If the user is not the owner of the room, show a toast message
          CommonFunctions.showToast('خاص بمالك الغرفة', Colors.red);
        }

        break;
    }
  }

  //// Chose Image
  Future<File> pickImage(ImageSource source) async {
    var image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      imageFile = File(image.path);
      uploadImage();
      imagename = imageFile.path.split("/").last;
      print(imageFile.path);
      return imageFile;
    }
  }

  //// Pick Image with Camera
  Future<File> imagePicker(BuildContext context, ThemeData themeData) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: CupertinoActionSheet(
              title: Text(
                'التقاط الصورة عبر',
                // style: themeData.textTheme.subtitle,
              ),
              cancelButton: CupertinoButton(
                child: Text("اغلاق",
                    style: themeData.textTheme.bodyText1.copyWith(
                      color: kPrimaryColor,
                    )),
                onPressed: () => Navigator.pop(context),
              ),
              actions: <Widget>[
                CupertinoButton(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.photo_camera_solid,
                          color: themeData.primaryColor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "الكاميرا",
                          //  style: themeData.textTheme.body1,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      File imageFile = await pickImage(ImageSource.camera);
                      return imageFile;
                    }),
                CupertinoButton(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.insert_photo,
                          color: themeData.primaryColor,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "الاستوديو",
                          // style: themeData.textTheme.body1,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      File imageFile = await pickImage(ImageSource.gallery);
                      return imageFile;
                    }),
              ],
            ),
          );
        });
  }

  //// Upload Image to firestore into chats collection inside chatroom collection
  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestoreInstance
        .collection('chatroom')
        .doc(widget.roomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": specialId,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    //// Delete the image if Error has been catched
    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      await _firestoreInstance
          .collection('chatroom')
          .doc(widget.roomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestoreInstance
          .collection('chatroom')
          .doc(widget.roomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});
      onSendMessage(imageUrl, 1, 1);
      print(imageUrl);
    }
  }

  void showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _messageController.text += emoji.emoji; // Add to message
            Navigator.pop(context); // Close the picker
          },
        );
      },
    );
  }

// Optional - for clearing a selected emoji easily
  void _clearSelectedEmoji() {
    if (_messageController.text.isNotEmpty) {
      final text = _messageController.text;
      _messageController.text = text.substring(0, text.length - 2);
    }
  }

  //// Send New massage (content) from the user To the room chat , select the massage Type if text or image, etc ..
  //// By Hedra Adel
  void onSendMessage(
    String content,
    int type,
    int currentlevel,
  ) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      _messageController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.roomId)
          .collection(widget.roomId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'username': username,
            'idFrom': specialId,
            'idTo': widget.roomId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'userLevel': currentlevel,
            'ApiUserID': apiid,
            'userType': userstateInroom,
            'specialId': specialId,
            'packageName': nameOFPackage,
            'packageColor': packageColor,
            'packageBadge': packagebadge,
            'hasSpecialID': hasSpecialID
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      print("The Message has Been Sent" + "--- Hedra Adel ---");
    } else {
      CommonFunctions.showToast('Nothing to send', Colors.red);
      print("The Message hasn't Been Sent" + "--- Hedra Adel ---");
    }
  }

  /// Reads local data and updates the state.
  ///
  /// This function reads the room ID from the widget and updates the state variables `groupChatId` and `roomID`.

  Future<void> setRoomID() async {
    try {
      // Update the state variables with the room ID from the widget
      setState(() {
        groupChatId = '${widget.roomId}';
        roomID = widget.roomId;
      });
    } catch (e) {
      // If an exception is caught, print an error message to the console
      print("Error in readLocal(): " + e.toString());
    }
  }

// improve checkRoomFoundOrNot() code and handle the errors
//// Check the room is found or no in the firestore and update _isRoomOnFirebase bool variable and create room doc if it not exists
//// By Hedra Adel
  checkRoomFoundOrNot() async {
    try {
      DocumentSnapshot ds =
          await _firestoreInstance.collection("roomUsers").doc(roomID).get();
      this.setState(() {
        _isRoomOnFirebase = ds.exists;
        print("checkRoomFoundOrNot Has been Completed and " +
            "_isRoomOnFirebase is : $_isRoomOnFirebase" +
            "--- Hedra Adel ---");
      });
      // if room not exist add it to firebase
      _isRoomOnFirebase ? null : _addMicsToFirebase(roomID);
    } catch (e) {
      print("Error in checkRoomFoundOrNot: $e");
    }
  }
}

class BestRoomUsers extends StatelessWidget {
  const BestRoomUsers({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "قائمة الكرماء",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            //height: 568,
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: PreferredSize(
                    preferredSize: Size.fromHeight(30.0),
                    child: AppBar(
                      backgroundColor: Colors.white,
                      bottom: TabBar(
                        indicator: BoxDecoration(
                          color: KstorebuttonColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        tabs: [
                          Text(
                            "اخر 24 ساعة",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "اخر 7 أيام",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )),
                body: TabBarView(
                  children: [
                    ListView(children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.white,
                              child: Icon(
                                Icons.hourglass_empty_rounded,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "لم يرسل أحد الهدايا في ال 24 ساعة الماضية",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(
                            height: 240,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30.0,
                                          backgroundImage: NetworkImage(
                                              "https://images.unsplash.com/photo-1547665979-bb809517610d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80"),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("username"),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .monetization_on_rounded,
                                                      color: Colors.orange),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text("0"),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              )
                            ],
                          )
                        ],
                      ),
                    ]),
                    ListView(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 80,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: Colors.white,
                                child: Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "لم يرسل أحد الهدايا في السبعة أيام الماضية",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(
                              height: 240,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30.0,
                                            backgroundImage: NetworkImage(
                                                "https://images.unsplash.com/photo-1547665979-bb809517610d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80"),
                                            backgroundColor: Colors.transparent,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("username"),
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .monetization_on_rounded,
                                                        color: Colors.orange),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text("0"),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
