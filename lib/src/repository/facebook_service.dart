import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'facebook_service.g.dart';

class FacebookService {
  final Dio dio = Dio();

  Future<FacebookUserProfile> getUserProfile(
      FacebookCredential facebookCredential) async {
    final accessToken = facebookCredential.accessToken;
    final userId = facebookCredential.id;

    final graphResponse = await dio.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${accessToken}');
    final FacebookUserProfile fbUserProfile =
        FacebookUserProfile.fromJson(jsonDecode(graphResponse.data));
    var msg = '''
      Fb user
      User id: ${userId}
      Expires: ${facebookCredential.expiresAt}
      ''';
    developer.log(msg);
    return fbUserProfile;
  }
}

@JsonSerializable()
class FacebookCredential {
  final String? id;
  final String? accessToken;
  final String? expiresAt;

  FacebookCredential(
      {required this.id,
      required this.accessToken,
      required this.expiresAt});
  factory FacebookCredential.fromJson(Map<String, dynamic> json) =>
      _$FacebookCredentialFromJson(json);
  Map<String, dynamic> toJson() => _$FacebookCredentialToJson(this);
}

@JsonSerializable()
class FacebookUserProfile {
  final String? email;
  final String? name;
  final String? first_name;
  final String? last_name;

  FacebookUserProfile(
      {required this.email,
      required this.name,
      this.first_name,
      this.last_name});
  factory FacebookUserProfile.fromJson(Map<String, dynamic> json) =>
      _$FacebookUserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$FacebookUserProfileToJson(this);
}

@JsonSerializable()
class FacebookMeta {
  final String? id;
  final String? accessToken;
  final String? expiresAt;
  final String? email;
  final String? name;
  final String? first_name;
  final String? last_name;

  FacebookMeta(
      {required this.id,
      required this.accessToken,
      required this.expiresAt,
      required this.email,
      required this.name,
      required this.first_name,
      required this.last_name});

  factory FacebookMeta.fromJson(Map<String, dynamic> json) =>
      _$FacebookMetaFromJson(json);
  Map<String, dynamic> toJson() {
    // _$FacebookMetaToJson(this)
    return <String, dynamic>{
      'methodName': 'native-facebook',
      'accessToken': accessToken,
      'expiresIn': expiresAt,
      'userID': id
    };
  }
}
