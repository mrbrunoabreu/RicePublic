import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'index.dart';
import '../utils.dart';

@immutable
abstract class ReviewCommentsEvent {
  Future<Position> loadUserLocation() async {
    return await loadUserLastLocation();
  }

  Future<ReviewCommentsState?> applyAsync(
      {ReviewCommentsState? currentState, ReviewCommentsBloc? bloc});
  // final ReviewCommentsRepository _ReviewCommentsRepository = ReviewCommentsRepository();
}

class UnReviewCommentsEvent extends ReviewCommentsEvent {
  @override
  Future<ReviewCommentsState> applyAsync(
      {ReviewCommentsState? currentState, ReviewCommentsBloc? bloc}) async {
    if (currentState is InReviewCommentsState) {
      currentState.commentsSubscription.unsubscribe();
    }
    return UnReviewCommentsState(0);
  }
}

class LoadReviewCommentsEvent extends ReviewCommentsEvent {
  final bool isError;
  final String? id;
  @override
  String toString() => 'LoadReviewCommentsEvent';

  LoadReviewCommentsEvent(this.isError, this.id);

  @override
  Future<ReviewCommentsState> applyAsync(
      {ReviewCommentsState? currentState, ReviewCommentsBloc? bloc}) async {
    try {
      if (currentState is InReviewCommentsState) {
        return currentState;
      }
      final subscription = bloc!.subscribeRestaurantReviewComments(id);

      return InReviewCommentsState(0, subscription);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadReviewCommentsEvent', error: _, stackTrace: stackTrace);
      return ErrorReviewCommentsState(0, _.toString());
    }
  }
}

class SendCommentEvent extends ReviewCommentsEvent {
  final String? reviewId;
  final String text;

  SendCommentEvent({required this.reviewId, required this.text});

  @override
  Future<ReviewCommentsState?> applyAsync({
    ReviewCommentsState? currentState,
    ReviewCommentsBloc? bloc,
  }) async {
    if (currentState is InReviewCommentsState) {
      await bloc!.commentReview(text, reviewId);
    }
    return currentState;
  }
}
