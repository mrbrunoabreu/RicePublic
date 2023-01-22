import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import '../model/plan.dart';
import '../model/restaurant.dart';
import '../model/user.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final String? name;
  final String? bio;
  final String? favoriteFood;
  final String? cantEatFood;
  final ProfilePic? picture;

  final String? location;

  final List<String?>? languages;

  @JsonKey(name: "isFollowed")
  bool? isFollowedByUser;
  @JsonKey(name: "isFollowing")
  bool? isFollowingUser;

  final String? userId;

  String? favoriteListId;

  final List<String>? following;
  final List<String>? followers;
  @JsonKey(name: "restaurantsBeenTo")
  final List<String>? beenTo;
  @JsonKey(name: "restaurantsWantTo")
  final List<String>? wantToGo;

  List<Plan>? upcomingPlans;
  List<String>? photos;
  List<Restaurant>? favorites;
  List<ListMetadata>? lists;

  Profile({
    required this.bio,
    required this.favoriteFood,
    required this.cantEatFood,
    required this.name,
    required this.picture,
    this.userId = "",
    this.location = "",
    this.languages = const [],
    this.isFollowedByUser = false,
    this.isFollowingUser = true,
    this.following = const [],
    this.followers = const [],
    this.beenTo = const [],
    this.wantToGo = const [],
    this.upcomingPlans = const [],
    this.photos = const [],
    this.favorites = const [],
    this.lists = const [],
    this.favoriteListId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    if (json['beenTo'] != null && json['beenTo'] is int) {
      json['beenTo'] = [];
    }
    if (json['wantToGo'] != null && json['wantToGo'] is int) {
      json['wantToGo'] = [];
    }
    final Profile profile = _$ProfileFromJson(json);
    if (profile.isFollowedByUser == null) {
      profile.isFollowedByUser = false;
    }
    if (profile.isFollowingUser == null) {
      profile.isFollowingUser = false;
    }
    return profile;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$ProfileToJson(this);
    if (bio != null && bio!.isEmpty) {
      json.remove("bio");
    }
    if (favoriteFood != null && favoriteFood!.isEmpty) {
      json.remove("favoriteFood");
    }
    if (cantEatFood != null && cantEatFood!.isEmpty) {
      json.remove("cantEatFood");
    }
    return json;
  }

  @override
  String toString() => _$ProfileToString(this);
}

@JsonSerializable()
class ProfilePic {
  final String? url;
  final String? relative_url;

  ProfilePic({required this.url, this.relative_url = ""});
  factory ProfilePic.fromJson(Map<String, dynamic> json) =>
      _$ProfilePicFromJson(json);

  Map<String, dynamic> toJson() => _$ProfilePicToJson(this);
}

@JsonSerializable()
class ListMetadata {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? shortDescription;
  final List<UserListItem>? items;
  String? photo;

  ListMetadata({
    required this.id,
    required this.name,
    required this.items,
    required this.photo,
    required this.shortDescription,
  });

  factory ListMetadata.fromJson(Map<String, dynamic> json) {
    final parsed = _$ListMetadataFromJson(json);

    if (parsed.photo == null) {
      final restaurants = List.of(json['items'] ?? [])
          .where((e) => e['restaurant'] != null)
          .map((e) => Restaurant.fromJson(e['restaurant']))
          .where((e) => e.photo != null)
          .toList();

      if (restaurants.isNotEmpty) {
        parsed.photo = restaurants.last.photo;
      }
    }

    return parsed;
  }

  Map<String, dynamic> toJson() => _$ListMetadataToJson(this);
}

@JsonSerializable()
class FavoriteMetadata {
  final String? name;
  final String? photo;
  final String? location;

  FavoriteMetadata({
    required this.name,
    required this.photo,
    this.location,
  });

  factory FavoriteMetadata.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteMetadataToJson(this);
}

class CreatePersonalList {
  final String name;
  final File? cover;

  CreatePersonalList({
    required this.name,
    required this.cover,
  });
}

@JsonSerializable()
class UserListItem {
  final String? restaurantId;
  final Restaurant? restaurant;
  final UserItem? user;
  final String? comment;

  UserListItem(
      {required this.restaurantId, this.restaurant, this.user, this.comment});
  factory UserListItem.fromJson(Map<String, dynamic> json) =>
      _$UserListItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserListItemToJson(this);
}

@JsonSerializable()
class UserItem {
  final String? userId;
  final String? userName;

  UserItem({required this.userId, this.userName});
  factory UserItem.fromJson(Map<String, dynamic> json) =>
      _$UserItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemToJson(this);
}
