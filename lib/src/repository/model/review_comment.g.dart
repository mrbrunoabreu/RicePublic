// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewComment _$ReviewCommentFromJson(Map<String, dynamic> json) {
  return ReviewComment(
    id: json['_id'] as String?,
    userReviewId: json['userReviewId'] as String?,
    userId: json['userId'] as String?,
    comment: json['comment'] as String?,
    dateCreated: json['dateCreated'] == null ? null : json['dateCreated'],
  );
}

Map<String, dynamic> _$ReviewCommentToJson(ReviewComment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userReviewId': instance.userReviewId,
      'userId': instance.userId,
      'comment': instance.comment,
      'dateCreated': instance.dateCreated?.toIso8601String(),
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$ReviewCommentToString(ReviewComment o) {
  return """ReviewComment{id: ${o.id}, userReviewId: ${o.userReviewId}, userId: ${o.userId}, comment: ${o.comment}, dateCreated: ${o.dateCreated}}""";
}
