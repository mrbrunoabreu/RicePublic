// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) {
  return Plan(
    id: json['_id'] as String?,
    userId: json['userId'] as String?,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    restaurantId: json['restaurantId'] as String?,
    restaurant: json['restaurant'] == null
        ? null
        : Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
    postId: json['postId'] as String?,
    isPublic: json['isPublic'] as bool?,
    isJoinable: json['isJoinable'] as bool?,
    isFollowersOnly: json['isFollowersOnly'] as bool?,
    deleted: json['deleted'] as bool?,
    hasPosted: json['hasPosted'] as bool?,
    usersIds: (json['usersIds'] as List?)?.map((e) => e as String)?.toList(),
    users: (json['users'] as List?)
        ?.map(
            (e) => User.fromJson(e as Map<String, dynamic>))
        .toList(),
    period: json['period'] as String?,
    additionalComments: json['additionalComments'] as String?,
    dateCreated: json['dateCreated'] == null
        ? null
        : DateTime.parse(json['dateCreated'] as String),
    planDate: json['planDate'] == null
        ? null
        : DateTime.parse(json['planDate'] as String),
  );
}

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'user': instance.user,
      'restaurantId': instance.restaurantId,
      'restaurant': instance.restaurant,
      'postId': instance.postId,
      'isPublic': instance.isPublic,
      'isJoinable': instance.isJoinable,
      'isFollowersOnly': instance.isFollowersOnly,
      'deleted': instance.deleted,
      'hasPosted': instance.hasPosted,
      'usersIds': instance.usersIds,
      'users': instance.users,
      'period': instance.period,
      'additionalComments': instance.additionalComments,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'planDate': instance.planDate?.toIso8601String(),
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$PlanToString(Plan o) {
  return """Plan{id: ${o.id}, userId: ${o.userId}, user: ${o.user}, restaurantId: ${o.restaurantId}, restaurant: ${o.restaurant}, postId: ${o.postId}, isPublic: ${o.isPublic}, isJoinable: ${o.isJoinable}, isFollowersOnly: ${o.isFollowersOnly}, deleted: ${o.deleted}, hasPosted: ${o.hasPosted}, usersIds: ${o.usersIds}, users: ${o.users}, period: ${o.period}, additionalComments: ${o.additionalComments}, dateCreated: ${o.dateCreated}, planDate: ${o.planDate}}""";
}
