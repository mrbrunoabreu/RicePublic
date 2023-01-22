// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return Review(
    restaurantId: json['restaurantId'] as String?,
    comment: json['comment'] as String?,
    reviewRatings: json['reviewRatings'] == null
        ? null
        : ReviewRatings.fromJson(json['reviewRatings'] as Map<String, dynamic>),
    photos: (json['photos'] as List?)?.map((e) => e as String)?.toList(),
    likes: (json['likes'] as List?)?.map((e) => e as String)?.toList(),
    dateCreated: json['dateCreated'] == null
        ? null
        : DateTime.parse(json['dateCreated'] as String),
  );
}

Map<String, dynamic> _$ReviewToJson(Review instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('restaurantId', instance.restaurantId);
  val['reviewRatings'] = instance.reviewRatings;
  val['comment'] = instance.comment;
  writeNotNull('photos', instance.photos);
  writeNotNull('likes', instance.likes);
  writeNotNull('dateCreated', instance.dateCreated?.toIso8601String());
  return val;
}

ReviewRatings _$ReviewRatingsFromJson(Map<String, dynamic> json) {
  return ReviewRatings(
    overall: (json['overall'] as num?)?.toDouble(),
    ambience: (json['ambience'] as num?)?.toDouble(),
    food: (json['food'] as num?)?.toDouble(),
    service: (json['service'] as num?)?.toDouble(),
    value: (json['value'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$ReviewRatingsToJson(ReviewRatings instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'food': instance.food,
      'service': instance.service,
      'ambience': instance.ambience,
      'value': instance.value,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$ReviewToString(Review o) {
  return """Review{id: ${o.id}, userId: ${o.userId}, userName: ${o.userName}, userPhoto: ${o.userPhoto}, isFriend: ${o.isFriend}, restaurantId: ${o.restaurantId}, reviewRatings: ${o.reviewRatings}, comment: ${o.comment}, photos: ${o.photos}, likes: ${o.likes}, dateCreated: ${o.dateCreated}}""";
}

String _$ReviewRatingsToString(ReviewRatings o) {
  return """ReviewRatings{overall: ${o.overall}, food: ${o.food}, service: ${o.service}, ambience: ${o.ambience}, value: ${o.value}}""";
}
