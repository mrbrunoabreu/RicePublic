// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facebook_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacebookCredential _$FacebookCredentialFromJson(Map<String, dynamic> json) {
  return FacebookCredential(
    id: json['id'] as String?,
    accessToken: json['accessToken'] as String?,
    expiresAt: json['expiresAt'] as String?,
  );
}

Map<String, dynamic> _$FacebookCredentialToJson(FacebookCredential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accessToken': instance.accessToken,
      'expiresAt': instance.expiresAt,
    };

FacebookUserProfile _$FacebookUserProfileFromJson(Map<String, dynamic> json) {
  return FacebookUserProfile(
    email: json['email'] as String?,
    name: json['name'] as String?,
    first_name: json['first_name'] as String?,
    last_name: json['last_name'] as String?,
  );
}

Map<String, dynamic> _$FacebookUserProfileToJson(
        FacebookUserProfile instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
    };

FacebookMeta _$FacebookMetaFromJson(Map<String, dynamic> json) {
  return FacebookMeta(
    id: json['id'] as String?,
    accessToken: json['accessToken'] as String?,
    expiresAt: json['expiresAt'] as String?,
    email: json['email'] as String?,
    name: json['name'] as String?,
    first_name: json['first_name'] as String?,
    last_name: json['last_name'] as String?,
  );
}

Map<String, dynamic> _$FacebookMetaToJson(FacebookMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accessToken': instance.accessToken,
      'expiresAt': instance.expiresAt,
      'email': instance.email,
      'name': instance.name,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$FacebookCredentialToString(FacebookCredential o) {
  return """FacebookCredential{id: ${o.id}, accessToken: ${o.accessToken}, expiresAt: ${o.expiresAt}}""";
}

String _$FacebookUserProfileToString(FacebookUserProfile o) {
  return """FacebookUserProfile{email: ${o.email}, name: ${o.name}, first_name: ${o.first_name}, last_name: ${o.last_name}}""";
}

String _$FacebookMetaToString(FacebookMeta o) {
  return """FacebookMeta{id: ${o.id}, accessToken: ${o.accessToken}, expiresAt: ${o.expiresAt}, email: ${o.email}, name: ${o.name}, first_name: ${o.first_name}, last_name: ${o.last_name}}""";
}
