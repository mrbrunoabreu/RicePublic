import 'package:json_annotation/json_annotation.dart';
import '../model/profile.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  @JsonKey(ignore: true)
  String? id;
  @JsonKey(ignore: true)
  String? userId;
  @JsonKey(ignore: true)
  String? userName;
  @JsonKey(ignore: true)
  String? userPhoto;
  @JsonKey(ignore: true)
  bool? isFriend;

  @JsonKey(includeIfNull: false)
  String? restaurantId;
  ReviewRatings? reviewRatings;
  String? comment;
  @JsonKey(includeIfNull: false)
  List<String>? photos;
  @JsonKey(includeIfNull: false)
  List<String>? likes;
  @JsonKey(includeIfNull: false)
  DateTime? dateCreated;

  Review(
      {this.id,
      this.userId,
      this.restaurantId,
      this.comment,
      this.reviewRatings,
      this.userName,
      this.userPhoto,
      this.photos,
      this.likes,
      this.isFriend,
      this.dateCreated});

  factory Review.fromJson(Map<String, dynamic> json) => _reviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

Review _reviewFromJson(Map<String, dynamic> json) {
  var reviewRatingsJson = json['reviewRatings'];
  ReviewRatings? reviewRatings = reviewRatingsJson != null
      ? new ReviewRatings.fromJson(reviewRatingsJson)
      : null;
  var userPhoto = json['photo'];
  ProfilePic? profilePic =
      userPhoto != null ? new ProfilePic.fromJson(userPhoto) : null;
  return Review(
    id: json['_id'] as String?,
    restaurantId: json['restaurantId'] as String?,
    userId: json['userId'] as String?,
    userName: json['name'] as String?,
    userPhoto: profilePic?.url,
    reviewRatings: reviewRatings,
    comment: json['comment'] as String?,
    photos: (json['photos'] as List?)?.map((e) => e as String)?.toList(),
    likes: (json['likes'] as List?)?.map((e) => e as String)?.toList() ?? [],
    dateCreated:
        (json['dateCreated'] != null) ? json['dateCreated'] : DateTime.now(),
  );
}

@JsonSerializable()
class ReviewRatings {
  double? overall;
  double? food;
  double? service;
  double? ambience;
  double? value;

  ReviewRatings.withOneRating(double rating) {
    this.overall = rating;
    this.food = rating;
    this.service = rating;
    this.ambience = rating;
    this.value = rating;
  }

  ReviewRatings(
      {this.overall, this.ambience, this.food, this.service, this.value});

  factory ReviewRatings.fromJson(Map<String, dynamic> json) =>
      _reviewRatingsFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewRatingsToJson(this);
}

ReviewRatings _reviewRatingsFromJson(Map<String, dynamic> json) {
  double? overall = json['overall'].toDouble();
  double? food = json['food'].toDouble();
  double? service = json['service'].toDouble();
  double? ambience = json['ambience'].toDouble();
  double? value = json['value'].toDouble();
  return ReviewRatings(
      overall: overall,
      food: food,
      service: service,
      ambience: ambience,
      value: value);
}
