import 'package:json_annotation/json_annotation.dart';
import '../model/restaurant.dart';
import '../model/user.dart';

part 'plan.g.dart';

@JsonSerializable()
class Plan {
  @JsonKey(name: '_id')
  String? id;
  String? userId;
  User? user;
  String? restaurantId;
  Restaurant? restaurant;
  String? postId;

  bool? isPublic;
  bool? isJoinable;
  bool? isFollowersOnly;
  bool? deleted;
  bool? hasPosted;

  List<String>? usersIds;
  List<User>? users;

  String? period;
  String? additionalComments;

  DateTime? dateCreated;
  DateTime? planDate;

  Plan({
    this.id,
    this.userId,
    this.user,
    this.restaurantId,
    this.restaurant,
    this.postId,
    this.isPublic,
    this.isJoinable,
    this.isFollowersOnly,
    this.deleted,
    this.hasPosted,
    this.usersIds,
    this.users,
    this.period,
    this.additionalComments,
    this.dateCreated,
    this.planDate,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => _planFromJson(json);

  Map<String, dynamic> toJson() => _$PlanToJson(this);
}

Plan _planFromJson(Map<String, dynamic> json) {
  Restaurant? restaurant = json['restaurant'] != null
      ? Restaurant.fromJson(json['restaurant'])
      : null;

  final planDate = DateTime.fromMicrosecondsSinceEpoch(
    json['planDate']['\$date'] * 1000,
  );

  return Plan(
    id: json['_id'] as String?,
    userId: json['userId'] as String?,
    dateCreated: DateTime.fromMicrosecondsSinceEpoch(
      json['dateCreated']['\$date'],
    ),
    restaurantId: json['restaurantId'] as String?,
    planDate: planDate,
    isPublic: json['isPublic'] as bool? ?? false,
    isJoinable: json['isJoinable'] as bool?,
    isFollowersOnly: json['isFollowersOnly'] as bool?,
    usersIds: json['usersIds'] != null ? List.from(json['usersIds']) : null,
    users: json['users'] != null
        ? List.from(json['users'] ?? [])
            .map((json) => User.fromJson(json))
            .toList()
        : null,
    additionalComments: json['additionalComments'] as String?,
    period: json['period'] as String?,
    restaurant: restaurant,
    deleted: json['deleted'] as bool?,
    // user: User.fromJson(json['user']),
    hasPosted: json['hasPosted'] as bool?,
    postId: json['pepostIdriod'] as String?,
  );
}
