class FileData {
  String filename;
  String filepath;
  int filesize;
  String fileExtension;
  String mobileModel;
  String mobileName;
  String userId;

  FileData(
      {this.filename,
      this.filepath,
      this.filesize,
      this.fileExtension,
      this.mobileModel,
      this.mobileName,
      this.userId,
      DateTime lastModified});

  Map<String, dynamic> toJson() => {
        /* ... serialization logic ... */
        "filename": filename,
        "filepath": filepath,
        "filesize": filesize,
        "fileExtension": fileExtension,
        "mobileModel": mobileModel,
        "mobileName": mobileName,
        "userId": userId
      };

  // For deserialization from JSON
  factory FileData.fromJson(Map<String, dynamic> json) => FileData(
      filename: json['filename'],
      filepath: json['filepath'],
      filesize: json['filesize'],
      fileExtension: json['fileExtension'],
      mobileModel: json['mobileModel'],
      mobileName: json['mobileName'],
      userId: json['userId']);
}
