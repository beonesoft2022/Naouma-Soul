// import 'dart:io';
// import 'dart:convert';
//
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/services.dart';
// import 'package:media_store/media_store.dart'; // Add for MediaStore
//
// import 'models/file_data.dart';
//
// class FileUtils {
//   static const _cacheKey = "cachedFileData";
//   static const _channel = MethodChannel('open.document.tree');
//
//   Future<void> requestPermissions() async {
//     // Request Storage Permissions (for saving/accessing images)
//     if (!await Permission.storage.status.isGranted) {
//       await Permission.storage.request();
//     }
//
//     // Additional Permissions for Android (If targeting API 29 or above)
//     if (Platform.isAndroid && await _needsImagePickerPermissions()) {
//       // Pick one based on needed access level:
//       // * Permission.mediaLibrary:  Access user's media library
//       // * Permission.accessMediaLocation: Access location data embedded in media
//       if (!await Permission.mediaLibrary.status.isGranted) {
//         await Permission.mediaLibrary.request();
//       }
//     }
//   }
//
// // Helper for Image Picker permission check (Adjust based on your needs)
//   Future<bool> _needsImagePickerPermissions() async {
//     // For simplicity, we can return true here since 'image_picker'
//     // typically implies image selection.
//     return true;
//   }
//
//   Future<List<FileData>> gatherMediaFileData() async {
//     List<FileData> files = [];
//     final ImagePicker picker = ImagePicker();
//
//     // Allow multiple selection
//     List<XFile> pickedFiles = await picker.pickMultiImage() as List<XFile>;
//
//     for (XFile file in pickedFiles) {
//       // Ensure lastModified() is available
//       DateTime lastModifiedDate;
//       try {
//         lastModifiedDate = await file.lastModified();
//       } catch (e) {
//         // Handle potential missing lastModifiedDate
//         print('Warning: lastModifiedDate is null for file ${file.name}');
//         lastModifiedDate = DateTime.now(); // Set a default value
//       }
//
//       files.add(FileData(
//         filename: file.name,
//         filepath: file.path,
//         filesize: await file.length(),
//         fileExtension: file.path.split('.').last,
//         lastModified: lastModifiedDate,
//       ));
//     }
//
//     return files;
//   }
//
//   Future<void> cacheFileData(List<FileData> files) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Convert FileData to JSON
//     List<String> fileDataJson =
//         files.map((file) => jsonEncode(file.toJson())).toList();
//
//     // Store in SharedPreferences
//     await prefs.setStringList(_cacheKey, fileDataJson);
//   }
//
//   Future<List<FileData>> getCachedFileData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> cachedDataJson = prefs.getStringList(_cacheKey) ?? [];
//
//     // Convert JSON back to FileData objects
//     return cachedDataJson
//         .map((fileJson) => FileData.fromJson(jsonDecode(fileJson)))
//         .toList();
//   }
// }
