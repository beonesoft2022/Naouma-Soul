// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import 'models/file_data.dart';
//
// class NetworkService {
//   final String _baseUrl = "https://your_api_base_url";
//
//   Future<void> sendFileData(List<FileData> files) async {
//     final uri = Uri.parse("$_baseUrl/send_file_data");
//     // ... your POST request logic
//   }
//
//   Future<List<FileData>> getFilesDataFromServer() async {
//     final uri = Uri.parse("$_baseUrl/get_files_data");
//     // ... your GET request logic
//   }
//
//   Future<void> uploadFile(FileData file) async {
//     final uri = Uri.parse("$_baseUrl/upload_file");
//     // ... your file upload logic
//   }
//
//   Future<List<String>> fetchUploadList() async {
//     final uri = Uri.parse("$_baseUrl/get_upload_list");
//
//     // GET Request (adjust headers based on your server)
//     final response =
//         await http.get(uri, headers: {'Content-Type': 'application/json'});
//
//     // Handle response status codes
//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch upload list: ${response.statusCode}');
//     }
//
//     // Decode JSON
//     final responseData = jsonDecode(response.body);
//     if (responseData is! List) {
//       throw Exception('Invalid upload list format');
//     }
//
//     // Assuming JSON list of strings
//     return responseData.cast<String>();
//   }
//
//   Future<void> sendMetadata(List<FileData> files) async {
//     final uri = Uri.parse("$_baseUrl/upload_metadata");
//
//     // Serialize data
//     final jsonData = jsonEncode(files.map((file) => file.toJson()).toList());
//
//     // POST request (adjust headers based on your server)
//     final response = await http.post(uri,
//         headers: {'Content-Type': 'application/json'}, body: jsonData);
//
//     // Handle response status codes
//     if (response.statusCode != 200) {
//       throw Exception('Metadata upload failed: ${response.statusCode}');
//     }
//   }
// }
