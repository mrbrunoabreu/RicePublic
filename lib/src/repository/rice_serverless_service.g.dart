// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rice_serverless_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchUploadUrlRequest _$FetchUploadUrlRequestFromJson(
    Map<String, dynamic> json) {
  return FetchUploadUrlRequest(
    mimeType: json['type'] as String?,
    fileName: json['key'] as String?,
    bucketName: json['bucket'] as String?,
  );
}

Map<String, dynamic> _$FetchUploadUrlRequestToJson(
        FetchUploadUrlRequest instance) =>
    <String, dynamic>{
      'type': instance.mimeType,
      'key': instance.fileName,
      'bucket': instance.bucketName,
    };

FetchUploadUrlResponse _$FetchUploadUrlResponseFromJson(
    Map<String, dynamic> json) {
  return FetchUploadUrlResponse(
    uploadURL: json['uploadURL'] as String?,
  );
}

Map<String, dynamic> _$FetchUploadUrlResponseToJson(
        FetchUploadUrlResponse instance) =>
    <String, dynamic>{
      'uploadURL': instance.uploadURL,
    };

ImageHandlerRequest _$ImageHandlerRequestFromJson(Map<String, dynamic> json) {
  return ImageHandlerRequest(
    json['bucket'] as String?,
    json['key'] as String?,
    json['edits'] == null
        ? null
        : ImageHandlerEdits.fromJson(json['edits'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ImageHandlerRequestToJson(
        ImageHandlerRequest instance) =>
    <String, dynamic>{
      'bucket': instance.bucket,
      'key': instance.key,
      'edits': instance.edits,
    };

ImageHandlerEdits _$ImageHandlerEditsFromJson(Map<String, dynamic> json) {
  return ImageHandlerEdits(
    json['resize'] == null
        ? null
        : ImageResize.fromJson(json['resize'] as Map<String, dynamic>),
    normalize: json['normalize'] as bool?,
  );
}

Map<String, dynamic> _$ImageHandlerEditsToJson(ImageHandlerEdits instance) =>
    <String, dynamic>{
      'normalize': instance.normalize,
      'resize': instance.resize,
    };

ImageResize _$ImageResizeFromJson(Map<String, dynamic> json) {
  return ImageResize(
    json['width'] as int?,
    json['height'] as int?,
  );
}

Map<String, dynamic> _$ImageResizeToJson(ImageResize instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$FetchUploadUrlRequestToString(FetchUploadUrlRequest o) {
  return """FetchUploadUrlRequest{mimeType: ${o.mimeType}, fileName: ${o.fileName}, bucketName: ${o.bucketName}}""";
}

String _$FetchUploadUrlResponseToString(FetchUploadUrlResponse o) {
  return """FetchUploadUrlResponse{uploadURL: ${o.uploadURL}}""";
}

String _$ImageHandlerRequestToString(ImageHandlerRequest o) {
  return """ImageHandlerRequest{bucket: ${o.bucket}, key: ${o.key}, edits: ${o.edits}}""";
}

String _$ImageHandlerEditsToString(ImageHandlerEdits o) {
  return """ImageHandlerEdits{normalize: ${o.normalize}, resize: ${o.resize}}""";
}

String _$ImageResizeToString(ImageResize o) {
  return """ImageResize{width: ${o.width}, height: ${o.height}}""";
}
