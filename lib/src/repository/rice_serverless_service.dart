import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mime/mime.dart';
import '../../environment_config.dart';

part 'rice_serverless_service.g.dart';

class RiceServerlessService {
  static final String DEFAULT_BUCKET = EnvironmentConfig.S3_DEFAULT_BUCKET;
  static final String PROFILE_BUCKET = EnvironmentConfig.S3_PROFILE_BUCKET;
  static final String API_KEY = EnvironmentConfig.S3_API_KEY;

  static final String baseUrl = EnvironmentConfig.AWS_SERVERLESS_BASE_URL;
  static final String serverlessPhotoHandlerBaseUrl =
      EnvironmentConfig.AWS_PHOTO_HANDLER_URL;

  final Dio dio = Dio();

  Future<String?> _fetchUploadUrl(FetchUploadUrlRequest request) async {
    FetchUploadUrlResponse fetchUploadUrlResponse = await dio
        .post(
          baseUrl + '/requestUploadURL',
          data: json.encode(request.toJson()),
          options: Options(headers: {
            'Content-Type': 'application/json',
            'x-api-key': API_KEY
          }),
        )
        .then((response) => FetchUploadUrlResponse.fromJson(response.data));
    return fetchUploadUrlResponse.uploadURL;
  }

  static String _withoutExt(String fileName) {
    int index = fileName.lastIndexOf('.');
    if (index < 0 || index + 1 >= fileName.length) return fileName;
    return fileName.substring(0, index).toLowerCase();
  }

  static String _ext(String path) {
    int index = path.lastIndexOf('.');
    if (index < 0 || index + 1 >= path.length) return path;
    return path.substring(index + 1).toLowerCase();
  }

  Future<String> uploadProfilePicture(String? userId, File? file) async {
    if (file == null) return Future.value(null);

    // String base64Image = base64Encode(bytes);
    String fileName = file.path.split("/").last;
    int len = await file.length();
    FetchUploadUrlRequest request = fromBytes(
        await (file.openRead(0, 12).last as FutureOr<Uint8List>),
        fileName: fileName,
        name: "${DateTime.now().millisecondsSinceEpoch}-$userId",
        bucketName: PROFILE_BUCKET);
    String uploadUrl = await (_fetchUploadUrl(request) as FutureOr<String>);

    return dio
        .put(uploadUrl,
            data: file.openRead(),
            options: Options(headers: {
              Headers.contentLengthHeader: len,
            }))
        .then((response) {
      ImageHandlerRequest req = ImageHandlerRequest(PROFILE_BUCKET,
          request.fileName, ImageHandlerEdits(ImageResize(256, 256)));
      String photo = encJsonString(
          serverlessPhotoHandlerBaseUrl, json.encode(req.toJson()));
      developer.log(photo, name: 'uploadProfilePicture');
      return photo;
    });
  }

  Future<String> uploadRestaurantPicture(String? restaurantId, XFile file,
      {int quality = 100}) async {
    if (file == null) return Future.value(null);
    if (quality < 0 || quality > 100) {
      throw new ArgumentError.value(
          quality, 'quality should be in range 0-100');
    }

    Uint8List bytes = await file.readAsBytes();

    // John Check

    // ByteData byteData = await file.getThumbByteData(
    //     file.originalWidth!, file.originalHeight!,
    //     quality: quality);
    // List<int> bytes = byteData.buffer.asUint8List();
    // String base64Image = base64Encode(bytes);
    String fileName = file.name.split("/").last;
    String fileNameWithoutExt = _withoutExt(fileName);

    FetchUploadUrlRequest request = fromBytes(bytes,
        fileName: fileName,
        name: '${restaurantId}_$fileNameWithoutExt',
        bucketName: DEFAULT_BUCKET);
    String uploadUrl = await (_fetchUploadUrl(request) as FutureOr<String>);
    return dio
        .put(uploadUrl,
            data: Stream.fromIterable([bytes]),
            options: Options(headers: {
              Headers.contentLengthHeader: bytes.length,
            }))
        .then((response) {
      ImageHandlerRequest req = ImageHandlerRequest(DEFAULT_BUCKET,
          request.fileName, ImageHandlerEdits(ImageResize(512, 512)));
      String photo = encJsonString(
          serverlessPhotoHandlerBaseUrl, json.encode(req.toJson()));
      developer.log(photo, name: 'uploadRestaurantPicture');
      return photo;
    });
  }

  static String encJsonString(url, jsonString) {
    return '$url/${base64.encode(utf8.encode(jsonString))}';
  }

  static FetchUploadUrlRequest fromBytes(Uint8List bytes,
      {String? fileName,
      String? name,
      String? bucketName,
      bool appendExtName = true}) {
    String extFileName = _ext(fileName!);
    String? mime = lookupMimeType(fileName, headerBytes: bytes.sublist(0, 12));
    return FetchUploadUrlRequest(
        mimeType: mime,
        fileName: (appendExtName) ? '$name.$extFileName' : name,
        bucketName: bucketName);
  }
}

@JsonSerializable()
class FetchUploadUrlRequest {
  @JsonKey(name: "type")
  final String? mimeType;
  @JsonKey(name: "key")
  final String? fileName;
  @JsonKey(name: "bucket")
  final String? bucketName;

  FetchUploadUrlRequest({this.mimeType, this.fileName, this.bucketName});
  factory FetchUploadUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$FetchUploadUrlRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FetchUploadUrlRequestToJson(this);

  @override
  String toString() => _$FetchUploadUrlRequestToString(this);
}

@JsonSerializable()
class FetchUploadUrlResponse {
  final String? uploadURL;

  FetchUploadUrlResponse({this.uploadURL});
  factory FetchUploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchUploadUrlResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FetchUploadUrlResponseToJson(this);

  @override
  String toString() => _$FetchUploadUrlResponseToString(this);
}

@JsonSerializable()
class ImageHandlerRequest {
  final String? bucket; // S3 bucket name
  final String? key;
  final ImageHandlerEdits? edits;

  ImageHandlerRequest(this.bucket, this.key, this.edits);
  factory ImageHandlerRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageHandlerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ImageHandlerRequestToJson(this);

  @override
  String toString() => _$ImageHandlerRequestToString(this);
}

@JsonSerializable()
class ImageHandlerEdits {
  final bool? normalize;
  final ImageResize? resize;

  ImageHandlerEdits(this.resize, {this.normalize = true});
  factory ImageHandlerEdits.fromJson(Map<String, dynamic> json) =>
      _$ImageHandlerEditsFromJson(json);
  Map<String, dynamic> toJson() => _$ImageHandlerEditsToJson(this);

  @override
  String toString() => _$ImageHandlerEditsToString(this);
}

@JsonSerializable()
class ImageResize {
  final int? width;
  final int? height;

  ImageResize(this.width, this.height);
  factory ImageResize.fromJson(Map<String, dynamic> json) =>
      _$ImageResizeFromJson(json);
  Map<String, dynamic> toJson() => _$ImageResizeToJson(this);

  @override
  String toString() => _$ImageResizeToString(this);
}
