import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import '../repository/rice_repository.dart';
import 'index.dart';

class RestaurantReviewBloc
    extends BaseBloc<RestaurantReviewEvent, RestaurantReviewState> {
  RestaurantReviewBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnRestaurantReviewState(0));

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  Future postReview(
      Restaurant restaurant, Review review, List<XFile> photos) async {
    return await isLoggedIn().then((value) async {
      if (photos != null && photos.length > 0) {
        List<String> urls = await riceRepository
            .uploadReviewRestaurantPhotos(restaurant.id, photos, quality: 50);
        review.photos = urls;
      }
      return riceRepository.reviewRestaurant(restaurant, review);
    });
  }

  @override
  Future<void> mapEventToState(
    RestaurantReviewEvent event,
    Emitter<RestaurantReviewState> emitter,
  ) async {
    try {
      emitter(UnRestaurantReviewState(0));
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'RestaurantReviewBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
