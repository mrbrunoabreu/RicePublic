import '../model/restaurant.dart';
import '../model/review.dart';
import '../model/review_comment.dart';
import '../model/user.dart';

class TimelineReview {
  Review? review;
  User? user;
  Restaurant? restaurant;
  Future<List<ReviewComment>>? futureReviewComments;
  String? currentUserId;
  bool get isFollowing => (user?.profile?.followers != null &&
          user?.profile?.followers?.isNotEmpty == true)
      ? user!.profile!.followers!.contains(currentUserId)
      : false;

  TimelineReview({
    this.review,
    this.user,
    this.restaurant,
    this.currentUserId,
  });
}
