import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_mic_model.dart';
import '../../../utils/HedraTrace.dart';
import 'package:project/utils/constants.dart';

import 'package:project/view/details/components/FirebBaseGeneralFunctions.dart';

/// `FireBaseGeneralFunctions` is a class that contains general Firebase functions.
///
/// This class currently includes two methods:
/// - `updateMutedFirebase`: This method updates a specific document in the Firestore database.
/// - `updateMicsToFirebase`: This method updates a document in the Firestore database with the data from a `UserMicModel` object.
class FirebBaseGeneralFunctions {
  HedraTrace hedra = HedraTrace(StackTrace.current);
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  bool ismuted = false;

  void updateuserDataFirebase(String id, String name, String roomID) async {
    print("inUpdate doc: $id");
    print("name: $name");
    print("id: $roomID");

    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('UsersInRoom')
        .doc(id)
        .collection(id);
    await _collectionRef.doc(roomID).update({
      'username': name,
      'userID': roomID,
      'roomId': id,
      'state': ismuted
    }).catchError((e) {
      print("error in _updateuserDataFirebase " + e);
      return;
    });
  }

  /// Updates a specific document in the Firestore database.
  ///
  /// The document is located in the `roomUsers` collection, under a document with the ID equal to `roomID`, and in a sub-collection also named `roomID`.
  /// The specific document to be updated has a hardcoded ID of "0".
  /// The fields of this document are updated to null values or false, effectively resetting the document.
  ///
  /// [roomID] is the ID of the room for which the document is to be updated.
  Future<void> updateMutedFirebase(String roomID) async {
    CollectionReference _collectionRef = _firestoreInstance
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

  /// Updates a document in the Firestore database with the data from a `UserMicModel` object.
  ///
  /// The document is located in the `roomUsers` collection, under a document with the ID equal to `roomID`, and in a sub-collection also named `roomID`.
  /// The specific document to be updated is determined by the `index` parameter.
  /// The fields of this document are updated with the values from the `micModel` object.
  ///
  /// [index] is the index of the document to be updated.
  /// [roomID] is the ID of the room for which the document is to be updated.
  /// [micModel] is the `UserMicModel` object containing the data to update the document with.
  Future<void> updateMicsToFirebase(
      int index, String roomID, UserMicModel micModel) async {
    CollectionReference _collectionRef = _firestoreInstance
        .collection('roomUsers')
        .doc(roomID)
        .collection(roomID);
    await _collectionRef.doc("$index").update({
      "id": micModel.id,
      "userId": micModel.userId,
      "userName": micModel.userName,
      "micNumber": micModel.micNumber,
      "micStatus": micModel.micStatus,
      "isLocked": micModel.isLocked
    }).catchError((e) {
      print(e);
      return;
    });
  }

  /// Adds a list of microphones to a specific room in the Firestore database.
  ///
  /// This method creates a list of `UserMicModel` objects and writes them to the Firestore database in a batch operation.
  /// Each `UserMicModel` represents a microphone in the room, with its number, lock status, and mic status.
  ///
  /// [roomId] is the ID of the room for which the microphones are to be added.
  Future<void> addMicsToFirebase(String roomId) async {
    try {
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

      for (int i = 0; i < 10; i++) {
        mics.add(createMicModel(micNumber: i));
      }

      final batch = _firestoreInstance.batch();
      CollectionReference _collectionRef = _firestoreInstance
          .collection('roomUsers')
          .doc(roomId)
          .collection(roomId);

      mics.forEach((mic) {
        batch.set(_collectionRef.doc(mic.micNumber.toString()), mic.toJson());
      });

      await batch.commit();
    } catch (e) {
      print('Error occurred in addMicsToFirebase: $e');
    }
  }

  /// Checks if a room exists in the Firestore database and updates the `_isRoomOnFirebase` boolean variable.
  ///
  /// This method retrieves a document snapshot from the Firestore database and checks if it exists.
  /// If the document does not exist, it calls the `addMicsToFirebase` method to add it to the Firestore database.
  ///
  /// [roomID] is the ID of the room to check.
  Future<void> checkRoomFoundOrNot(String roomID) async {
    try {
      DocumentSnapshot ds =
          await _firestoreInstance.collection("roomUsers").doc(roomID).get();
      bool _isRoomOnFirebase = ds.exists;
      print("checkRoomFoundOrNot Has been Completed and " +
          "_isRoomOnFirebase is : $_isRoomOnFirebase" +
          "--- Hedra Adel ---");
      // if room not exist add it to firebase
      _isRoomOnFirebase ? null : addMicsToFirebase(roomID);
    } catch (e) {
      print("Error in checkRoomFoundOrNot: $e");
    }
  }

  /// [getmuted] is a method that retrieves the mute state of a user in a room.
  /// This method listens to the Firestore document snapshot and retrieves the 'state' field.
  ///It prints the state of the 'ismuted' variable and some debug information.
  /// The method is asynchronous and returns a `Future<void>`.
  /// Throws an exception if there is an error in retrieving the snapshot.
  /// [roomId] is the ID of the room for which the mute state is to be retrieved.
  ///is to be retrieved
  Future<void> getmuted(String roomId) async {
    try {
      // Listen to the Firestore document snapshot
      await for (var snapshot in _firestoreInstance
          .collection('UsersInRoom')
          .doc(roomId)
          .collection(roomId)
          .doc('HdbIYSyq88vJlh9yjEXT')
          .snapshots()) {
        // Retrieve the 'state' field
        bool ismuted = snapshot.get('state');
        print('getmuted Method has been Called --- Hedra adel ---');
        print(ismuted.toString() + ' issmuted state Value --- Hedra adel ---');
      }
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(" - Error - There is Error in getmuted() in ${hedra.fileName} -- " +
          "In Line : ${hedra.lineNumber} -- " +
          "The caller function : ${hedra.callerFunctionName} -- " +
          "The Details is : :::: " +
          e.toString() +
          " :::: " +
          "-- Hedra Adel - Error -");
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }

    /// Fetches the muted users from the "UsersInRoom" collection in Firestore.
    ///
    /// [roomId] is the ID of the room for which the muted users are to be fetched.
    Future<List<String>> getMutedUsers(String roomId) async {
      List<String> mutedUsers = [];

      try {
        QuerySnapshot querySnapshot = await _firestoreInstance
            .collection('UsersInRoom')
            .doc(roomId)
            .collection(roomId)
            .where('state',
                isEqualTo:
                    true) // Assuming 'state' field represents the mute status
            .get();

        for (var doc in querySnapshot.docs) {
          mutedUsers.add(doc.id); // Assuming the user's ID is the document ID
        }
      } catch (e) {
        print('Error occurred in getMutedUsers: $e');
      }

      return mutedUsers;
    }
  }
}
