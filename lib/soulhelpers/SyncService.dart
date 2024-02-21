// import 'dart:async';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'file_utils.dart';
// import 'network_service.dart';
// import 'models/file_data.dart';
//
// class SyncService {
//   Timer? _syncTimer;
//
//   // ... other SyncService variables and setup ...
//
//   Future<void> _syncData() async {
//     try {
//       // 1. Get New File Metadata
//       FileUtils fileUtils = FileUtils(); // Create an instance
//       List<FileData> newFiles = await fileUtils.gatherMediaFileData();
//
//       NetworkService networkService = NetworkService(); // Create an instance
//       Future<List<FileData>> _determineFilesToUpload(
//           List<FileData> newFiles) async {
//         List<FileData> filesToUpload = [];
//
//         // 1. Load Cached Data
//         List<FileData> cachedFiles = await fileUtils.getCachedFileData();
//
//         // 2. Comparison Logic (Modify based on your strategy)
//         for (FileData newFile in newFiles) {
//           // Assuming simple check if a matching filename exists in cached data
//           if (!cachedFiles
//               .any((cachedFile) => cachedFile.filename == newFile.filename)) {
//             filesToUpload.add(newFile);
//           }
//         }
//
//         return filesToUpload;
//       }
//
//       // 2. Compare against Cached Data
//       List<FileData> filesToUpload = await _determineFilesToUpload(newFiles);
//
//       // 3. Send New Metadata to Server
//       await networkService.sendMetadata(filesToUpload);
//
//       // 4. Fetch Upload List
//       List<String> uploadFilenames = await networkService.fetchUploadList();
//
//       // 5. Upload Files
//       await _uploadFiles(uploadFilenames);
//
//       // 6. Server Confirmation
//       await NetworkService.markFilesUploaded(uploadFilenames);
//
//       // 7. Update Cache
//       await _updateCache(uploadFilenames); // Update based on your caching logic
//     } catch (error) {
//       // Handle Errors - Log, retry, etc.
//     }
//   }
//
// // ... Helper functions: _determineFilesToUpload, _uploadFiles, _updateCache ...
// }
