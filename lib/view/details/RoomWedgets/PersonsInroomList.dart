// persons_in_room_list.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:project/models/user_mic_model.dart';
import 'package:project/utils/common_functions.dart';
import 'package:project/utils/preferences_services.dart';

import '../../../common_functions.dart';
import '../../../utils/constants.dart';
import '../components/mic_click_dialog.dart';
import 'package:project/view/details/components/RoomGeneralFunctions.dart';
import 'package:project/view/details/components/FirebBaseGeneralFunctions.dart';

class PersonsInroomList extends StatelessWidget {
  final int index;
  final UserMicModel micModel;
  List<UserMicModel> _micUsersList = [];

  PersonsInroomList({Key key, this.index, this.micModel, this.roomID})
      : super(key: key);

  //RoomGeneralFunctions roomGeneralFunctions = RoomGeneralFunctions();
  FirebBaseGeneralFunctions firebaseGeneralFunctions =
      FirebBaseGeneralFunctions();

  final String roomID;

  @override
  Widget build(BuildContext context) {
    print("_personInRoom index" + "$index" + "--- Hedra Adel ---");
    print(
        "_personInRoom index" + "${micModel.userName}" + "--- Hedra Adel ---");

    if (micModel != null) {
      return Expanded(
        child: Container(
          child: Column(
            children: <Widget>[
              micModel.micStatus == true
                  ? Flexible(
                      child: Stack(
                        children: [
                          hasFrame == null
                              ? Container(
                                  /*   // width: 70,
                                              // child: Image.network(
                                              //   hasFrame, */
                                  // )
                                  )
                              : Container(
                                  width: 70,
                                  child: Image.network(
                                    hasFrame,
                                  )), // Back image
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
          if (ismuted == true) {
            CommonFunctions.showToast('لا تملك الصلاحية', Colors.red);
          } else if (!micModel.micStatus &&
              !micModel.isLocked &&
              micModel.userId == null &&
              micModel.roomOwnerId == PreferencesServices.getString(ID_KEY)) {
            // Iam room owner and mic is empty
            print("Iam owner and mic is empty.");

            // Check if user already holds mic before
            var existingItem = _micUsersList.firstWhere(
                (itemToCheck) =>
                    itemToCheck.userId == PreferencesServices.getString(ID_KEY),
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            existingItem.micNumber, roomID, existingItem);
                        print("existname: ${existingItem.userName}");
                        print("existuserId: ${existingItem.userId}");
                        print("existmicNumber: ${existingItem.micNumber}");
                        print("existid: ${existingItem.micNumber}");
                        print("existmicStatus: ${existingItem.micStatus}");

                        // go to new mic
                        micModel.id = index.toString();
                        micModel.userName =
                            PreferencesServices.getString(Name_KEY);
                        micModel.userId = PreferencesServices.getString(ID_KEY);
                        micModel.micNumber = index;
                        micModel.micStatus = true;
                        print("name: ${micModel.userName}");
                        print("userId: ${micModel.userId}");
                        print("micNumber: ${micModel.micNumber}");
                        print("id: ${micModel.micNumber}");
                        print("micStatus: ${micModel.micStatus}");

                        /// Removes all previous screens from the back stack and redirect to new screen with provided screen tag
                        finish(context);

                        firebaseGeneralFunctions.updateMicsToFirebase(
                            existingItem.micNumber, roomID, existingItem);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        micModel.userName =
                            PreferencesServices.getString(Name_KEY);
                        micModel.userId = PreferencesServices.getString(ID_KEY);
                        micModel.micNumber = index;
                        micModel.micStatus = true;
                        micModel.isLocked = false;
                        print("name: ${micModel.userName}");
                        print("userId: ${micModel.userId}");
                        print("micNumber: ${micModel.micNumber}");
                        print("id: ${micModel.micNumber}");
                        print("micStatus: ${micModel.micStatus}");
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
              micModel.roomOwnerId == PreferencesServices.getString(ID_KEY)) {
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
              micModel.userId == PreferencesServices.getString(ID_KEY) &&
              micModel.roomOwnerId == PreferencesServices.getString(ID_KEY)) {
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
              micModel.roomOwnerId != PreferencesServices.getString(ID_KEY)) {
            // Iam not room owner and mic is locked
            print("Iam not room owner and mic is taken by me...");
            var existingItem = _micUsersList.firstWhere(
                (itemToCheck) =>
                    itemToCheck.userId == PreferencesServices.getString(ID_KEY),
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            existingItem.micNumber, roomID, existingItem);
                        print("existname: ${existingItem.userName}");
                        print("existuserId: ${existingItem.userId}");
                        print("existmicNumber: ${existingItem.micNumber}");
                        print("existid: ${existingItem.micNumber}");
                        print("existmicStatus: ${existingItem.micStatus}");

                        // go to new mic
                        micModel.id = index.toString();
                        micModel.userName =
                            PreferencesServices.getString(Name_KEY);
                        micModel.userId = PreferencesServices.getString(ID_KEY);
                        micModel.micNumber = index;
                        micModel.micStatus = true;
                        print("name: ${micModel.userName}");
                        print("userId: ${micModel.userId}");
                        print("micNumber: ${micModel.micNumber}");
                        print("id: ${micModel.micNumber}");
                        print("micStatus: ${micModel.micStatus}");
                        // update firebase
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                        firebaseGeneralFunctions.updateMicsToFirebase(
                            index, roomID, micModel);
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
              micModel.userId != PreferencesServices.getString(ID_KEY)) {
            // Mic is locked
            CommonFunctions.showToast("Mic is locked", Colors.red);
          } else {
            print("_micUsersList: ${_micUsersList.length}");
            //find existing item per link criteria
            var existingItem = _micUsersList.firstWhere(
                (itemToCheck) =>
                    itemToCheck.userId == PreferencesServices.getString(ID_KEY),
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
                      print("existname: ${existingItem.userName}");
                      print("existuserId: ${existingItem.userId}");
                      print("existmicNumber: ${existingItem.micNumber}");
                      print("existid: ${existingItem.micNumber}");
                      print("existmicStatus: ${existingItem.micStatus}");

                      // go to new mic
                      micModel.id = index.toString();
                      micModel.userName =
                          PreferencesServices.getString(Name_KEY);
                      micModel.userId = PreferencesServices.getString(ID_KEY);
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      finish(context);
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
                      micModel.userName =
                          PreferencesServices.getString(Name_KEY);
                      micModel.userId = PreferencesServices.getString(ID_KEY);
                      micModel.micNumber = index;
                      micModel.micStatus = true;
                      print("name: ${micModel.userName}");
                      print("userId: ${micModel.userId}");
                      print("micNumber: ${micModel.micNumber}");
                      print("id: ${micModel.micNumber}");
                      print("micStatus: ${micModel.micStatus}");
                      finish(context);
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
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
                      firebaseGeneralFunctions.updateMicsToFirebase(
                          micModel.micNumber, roomID, micModel);
                      finish(context);
                    });
                  });
            }
          }
        }),
      );
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
}
