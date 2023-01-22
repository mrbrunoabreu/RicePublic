// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['_id'] as String?,
    username: json['username'] as String?,
    emails: (json['emails'] as List?)
        ?.map(
            (e) => Email.fromJson(e as Map<String, dynamic>))
        .toList(),
    profile: json['profile'] == null
        ? null
        : Profile.fromJson(json['profile'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'emails': instance.emails,
      'profile': instance.profile,
    };

Email _$EmailFromJson(Map<String, dynamic> json) {
  return Email(
    address: json['address'] as String?,
    isVerified: json['isVerified'] as bool?,
  );
}

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'address': instance.address,
      'isVerified': instance.isVerified,
    };

Credential _$CredentialFromJson(Map<String, dynamic> json) {
  return Credential(
    id: json['id'] as String?,
    token: json['token'] as String?,
    tokenExpires: json['tokenExpires'] == null
        ? null
        : TokenExpire.fromJson(json['tokenExpires'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'tokenExpires': instance.tokenExpires,
    };

TokenExpire _$TokenExpireFromJson(Map<String, dynamic> json) {
  return TokenExpire(
    $date: json[r'$date'] as int?,
  );
}

Map<String, dynamic> _$TokenExpireToJson(TokenExpire instance) =>
    <String, dynamic>{
      r'$date': instance.$date,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$UserToString(User o) {
  return """User{id: ${o.id}, username: ${o.username}, emails: ${o.emails}, profile: ${o.profile}}""";
}

String _$EmailToString(Email o) {
  return """Email{address: ${o.address}, isVerified: ${o.isVerified}}""";
}

String _$CredentialToString(Credential o) {
  return """Credential{id: ${o.id}, token: ${o.token}, tokenExpires: ${o.tokenExpires}}""";
}
