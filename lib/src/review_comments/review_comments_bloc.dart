import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/model/review_comment.dart';
import '../repository/rice_meteor_service.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/review_comments/index.dart';
import '../base_bloc.dart';

class ReviewCommentsBloc
    extends BaseBloc<ReviewCommentsEvent, ReviewCommentsState> {
  ReviewCommentsBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnReviewCommentsState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<ReviewComment>> getReviewComments(
      String reviewId, int numOfLatest) {
    return riceRepository.getReviewComments(reviewId, numOfLatest);
  }

  ReviewCommentsSubscription subscribeRestaurantReviewComments(
      String? reviewId) {
    return riceRepository.subscribeRestaurantReviewComments(reviewId);
  }

  Future<ReviewComment> commentReview(String comment, String? reviewId) {
    return riceRepository.commentReview(comment, reviewId);
  }

  @override
  Future<void> mapEventToState(
    ReviewCommentsEvent event,
    Emitter<ReviewCommentsState> emitter,
  ) async {
    try {
      emitter(await (event.applyAsync(currentState: state, bloc: this)
          as FutureOr<ReviewCommentsState>));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ReviewCommentsBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
