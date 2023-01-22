// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    bio: json['bio'] as String?,
    favoriteFood: json['favoriteFood'] as String?,
    cantEatFood: json['cantEatFood'] as String?,
    name: json['name'] as String?,
    picture: json['picture'] == null
        ? null
        : ProfilePic.fromJson(json['picture'] as Map<String, dynamic>),
    userId: json['userId'] as String?,
    location: json['location'] as String?,
    languages: (json['languages'] as List?)?.map((e) => e as String)?.toList(),
    isFollowedByUser: json['isFollowed'] as bool?,
    isFollowingUser: json['isFollowing'] as bool?,
    following: (json['following'] as List?)?.map((e) => e as String)?.toList(),
    followers: (json['followers'] as List?)?.map((e) => e as String)?.toList(),
    beenTo:
        (json['restaurantsBeenTo'] as List?)?.map((e) => e as String)?.toList(),
    wantToGo:
        (json['restaurantsWantTo'] as List?)?.map((e) => e as String)?.toList(),
    upcomingPlans: (json['upcomingPlans'] as List?)
        ?.map(
            (e) => Plan.fromJson(e as Map<String, dynamic>))
        .toList(),
    photos: (json['photos'] as List?)?.map((e) => e as String)?.toList(),
    favorites: (json['favorites'] as List?)
        ?.map((e) =>
            Restaurant.fromJson(e as Map<String, dynamic>))
        .toList(),
    lists: (json['lists'] as List?)
        ?.map((e) =>
            ListMetadata.fromJson(e as Map<String, dynamic>))
        .toList(),
    favoriteListId: json['favoriteListId'] as String?,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'name': instance.name,
      'bio': instance.bio,
      'favoriteFood': instance.favoriteFood,
      'cantEatFood': instance.cantEatFood,
      'picture': instance.picture,
      'location': instance.location,
      'languages': instance.languages,
      'isFollowed': instance.isFollowedByUser,
      'isFollowing': instance.isFollowingUser,
      'userId': instance.userId,
      'favoriteListId': instance.favoriteListId,
      'following': instance.following,
      'followers': instance.followers,
      'restaurantsBeenTo': instance.beenTo,
      'restaurantsWantTo': instance.wantToGo,
      'upcomingPlans': instance.upcomingPlans,
      'photos': instance.photos,
      'favorites': instance.favorites,
      'lists': instance.lists,
    };

ProfilePic _$ProfilePicFromJson(Map<String, dynamic> json) {
  return ProfilePic(
    url: json['url'] as String?,
    relative_url: json['relative_url'] as String?,
  );
}

Map<String, dynamic> _$ProfilePicToJson(ProfilePic instance) =>
    <String, dynamic>{
      'url': instance.url,
      'relative_url': instance.relative_url,
    };

ListMetadata _$ListMetadataFromJson(Map<String, dynamic> json) {
  return ListMetadata(
    id: json['_id'] as String?,
    name: json['name'] as String?,
    items: (json['items'] as List?)
        ?.map((e) =>
            UserListItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    photo: json['photo'] as String?,
    shortDescription: json['shortDescription'] as String?,
  );
}

Map<String, dynamic> _$ListMetadataToJson(ListMetadata instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'shortDescription': instance.shortDescription,
      'items': instance.items,
      'photo': instance.photo,
    };

FavoriteMetadata _$FavoriteMetadataFromJson(Map<String, dynamic> json) {
  return FavoriteMetadata(
    name: json['name'] as String?,
    photo: json['photo'] as String?,
    location: json['location'] as String?,
  );
}

Map<String, dynamic> _$FavoriteMetadataToJson(FavoriteMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'photo': instance.photo,
      'location': instance.location,
    };

UserListItem _$UserListItemFromJson(Map<String, dynamic> json) {
  return UserListItem(
    restaurantId: json['restaurantId'] as String?,
    restaurant: json['restaurant'] == null
        ? null
        : Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : UserItem.fromJson(json['user'] as Map<String, dynamic>),
    comment: json['comment'] as String?,
  );
}

Map<String, dynamic> _$UserListItemToJson(UserListItem instance) =>
    <String, dynamic>{
      'restaurantId': instance.restaurantId,
      'restaurant': instance.restaurant,
      'user': instance.user,
      'comment': instance.comment,
    };

UserItem _$UserItemFromJson(Map<String, dynamic> json) {
  return UserItem(
    userId: json['userId'] as String?,
    userName: json['userName'] as String?,
  );
}

Map<String, dynamic> _$UserItemToJson(UserItem instance) => <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$ProfileToString(Profile o) {
  return """Profile{name: ${o.name}, bio: ${o.bio}, favoriteFood: ${o.favoriteFood}, cantEatFood: ${o.cantEatFood}, picture: ${o.picture}, location: ${o.location}, languages: ${o.languages}, isFollowedByUser: ${o.isFollowedByUser}, isFollowingUser: ${o.isFollowingUser}, userId: ${o.userId}, favoriteListId: ${o.favoriteListId}, following: ${o.following}, followers: ${o.followers}, beenTo: ${o.beenTo}, wantToGo: ${o.wantToGo}, upcomingPlans: ${o.upcomingPlans}, photos: ${o.photos}, favorites: ${o.favorites}, lists: ${o.lists}}""";
}

String _$ProfilePicToString(ProfilePic o) {
  return """ProfilePic{url: ${o.url}, relative_url: ${o.relative_url}}""";
}

String _$ListMetadataToString(ListMetadata o) {
  return """ListMetadata{id: ${o.id}, name: ${o.name}, shortDescription: ${o.shortDescription}, items: ${o.items}, photo: ${o.photo}}""";
}

String _$FavoriteMetadataToString(FavoriteMetadata o) {
  return """FavoriteMetadata{name: ${o.name}, photo: ${o.photo}, location: ${o.location}}""";
}

String _$UserListItemToString(UserListItem o) {
  return """UserListItem{restaurantId: ${o.restaurantId}, restaurant: ${o.restaurant}, user: ${o.user}, comment: ${o.comment}}""";
}

String _$UserItemToString(UserItem o) {
  return """UserItem{userId: ${o.userId}, userName: ${o.userName}}""";
}
