// lib/view/details/components/RoomGeneralFunctions.dart

import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/utils/images.dart';
import '../../../utils/HedraTrace.dart';
import 'package:project/view/details/components/FirebBaseGeneralFunctions.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/images.dart';
import 'package:cross_file/src/types/base.dart';
import 'package:cross_file/cross_file.dart';

class GeneralFunctions {
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  FirebBaseGeneralFunctions firebaseGeneralFunctions =
      FirebBaseGeneralFunctions();
  File imageFile;
  HedraTrace hedra = HedraTrace(StackTrace.current);
}
