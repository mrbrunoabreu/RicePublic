import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../model/profile.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;
  final String? username;
  final List<Email>? emails;
  final Profile? profile;

  User(
      {required this.id,
      required this.username,
      required this.emails,
      required this.profile});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => _$UserToString(this);
}

@JsonSerializable()
class Email {
  final String? address;
  final bool? isVerified;

  Email({required this.address, required this.isVerified});
  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);

  @override
  String toString() => address!;
}

@JsonSerializable()
class Credential {
  final String? id;
  final String? token;
  final TokenExpire? tokenExpires;

  Credential(
      {required this.id, required this.token, required this.tokenExpires});
  factory Credential.fromJson(Map<String, dynamic> json) {
    Credential c = _$CredentialFromJson(json);

    return c;
  }
  Map<String, dynamic> toJson() => _$CredentialToJson(this);
}

@JsonSerializable()
class TokenExpire {
  final int? $date;

  TokenExpire({required this.$date});
  factory TokenExpire.fromJson(Map<String, dynamic> json) =>
      _$TokenExpireFromJson(json);
  Map<String, dynamic> toJson() => _$TokenExpireToJson(this);

  @override
  String toString() {
    return _$TokenExpireToString(this);
  }

  String _$TokenExpireToString(TokenExpire o) {
    return """TokenExpire{${$date}: ${o.$date}}""";
  }
}
