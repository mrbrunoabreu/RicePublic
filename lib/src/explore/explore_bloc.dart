import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../repository/model/editorial.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/review_comment.dart';
import '../repository/rice_meteor_service.dart'
    show FollowingsRestaurantReviewsSubscription;
import '../repository/rice_repository.dart';

import '../base_bloc.dart';

class ExploreBloc extends BaseBloc<ExploreEvent, ExploreState> {
  ExploreBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnExploreState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<List<Restaurant>> fetchRecommendation(
      double currentLat, double currentLng) async {
    return riceRepository.restaurantsInRange(currentLat, currentLng);
  }

  Future<List<Plan>> fetchPublicPlans(
      double currentLat, double currentLng) async {
    // return riceRepository.restaurantsInRange(35.681236, 139.767125);
    return riceRepository.publicPlansByLocation(currentLat, currentLng);
  }

  Future<List<ReviewComment>> getReviewComments(
      String reviewId, int numOfLatest) {
    return riceRepository.getReviewComments(reviewId, numOfLatest);
  }

  Future<List<CarouselBanner>> fetchLatestPosts() async {
    return riceRepository.latestPosts();
  }

  Future<bool?> toggleLikeReview(String? reviewId) async {
    return riceRepository.toggleLikeReview(reviewId);
  }

  FollowingsRestaurantReviewsSubscription subscribeFollowingsReviews() =>
      riceRepository.subscribeFollowingsReviews();

  @override
  Future<void> mapEventToState(
    ExploreEvent event,
    Emitter<ExploreState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ExploreBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
