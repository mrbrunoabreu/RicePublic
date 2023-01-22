import 'package:json_annotation/json_annotation.dart';
import '../model/user.dart';

part 'review_comment.g.dart';

@JsonSerializable()
class ReviewComment {
  @JsonKey(name: '_id')
  String? id;

  String? userReviewId;
  String? userId;
  String? comment;
  DateTime? dateCreated;

  ReviewComment({
    this.id,
    this.userReviewId,
    this.userId,
    this.comment,
    this.dateCreated,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) =>
      _$ReviewCommentFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewCommentToJson(this);
}

class ReviewCommentWithUser extends ReviewComment {
  User? user;

  ReviewCommentWithUser(
    this.user, {
    String? id,
    String? userReviewId,
    String? userId,
    String? comment,
    DateTime? dateCreated,
  }) : super(
            id: id,
            userReviewId: userReviewId,
            userId: userId,
            comment: comment,
            dateCreated: dateCreated);
}
