import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/google_place_service.dart';
import '../repository/model/personal_list.dart';
import '../repository/model/profile.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/plan.dart';
import '../repository/model/review_comment.dart';
import '../repository/rice_meteor_service.dart';
import '../repository/rice_serverless_service.dart';

import 'facebook_service.dart';
import 'model/editorial.dart';
import 'model/plan.dart';
import 'model/review.dart';
import 'model/user.dart';
import 'model/chat.dart';

abstract class RiceRepository {
  Future<String> register(String name, String email);
  Future<String> login(String? email, String password);
  Future<String> loginWithFacebook(FacebookMeta meta);
  Future<String?> loginWithToken(String? token);
  Future<User> getCurrentUser();
  String? getCurrentUserId();
  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<List<Restaurant>> restaurantsInRange(double lat, double lng);
  Future<List<Restaurant>> restaurantsWithKeyword(
      String keyword, double lat, double lng);
  Future<List<Review>> restaurantReviews(String? restaurantId);
  Future<List<String>> restaurantPhotos(Restaurant? restaurant);
  Future<ReviewRatings> restaurantOverallRating(Restaurant restaurant);
  Future<Review> reviewRestaurant(Restaurant restaurant, Review review);
  Future<List<String>> uploadReviewRestaurantPhotos(
      String? restaurantId, List<XFile> files,
      {int quality = 100});
  Future<Profile> updateProfile(Profile? profile);
  Future<Profile> updateProfilePicture(File file, {int quality = 100});
  Future<Profile> updateProfileAndProfilePicture(Profile? profile, File? file);
  Future<String?> getLocationName(double lat, double lng);
  Future<List<Plan>> publicPlans(String datetime);
  Future<List<Plan>> publicPlansByLocation(double lat, double lng);
  Future<String?> createPlan(Plan plan);
  Future<List<User?>> getUserFriends(String query);
  Future<void> deletePlan(String? id);
  Future<Plan> updatePlan(Plan plan);
  Future<Plan> fetchPlan(String? id);
  Future<List<CarouselBanner>> latestPosts();
  ChatListSubscription findChats();

  Future<Profile> findProfile({required String? userId});
  Future<void> toggleFollowing({required String? userId});
  Future<void> toggleUnfollowing({required String? userId});
  Future<List<ListMetadata>> findPersonalLists({required String? userId});
  Future<PersonalList> findPersonalList({required String? listId});
  Future<void> savePersonalList({required CreatePersonalList personalList});
  Future<List<ChatMessage>> findChatMessages({required String chatId});
  ChatMessagesSubscription subscribeChatMessages(
      {required String? chatId, int? limit});
  Future<SendMessageMetadata> findSendChatMessageRequest({
    required String chatId,
  });
  Future<List<ChatPartner>> findChatPartners({
    required String name,
  });
  Future<ChatMetadata> startChat({
    required User? user,
  });
  Future<void> sendMessage({
    required String text,
    required ChatMetadata? chat,
  });

  Future<void> acceptSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  });

  Future<void> declineSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  });

  Future<void> ignoreSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  });

  Future<bool> toggleRestaurantWantToGoList(Restaurant? restaurant);
  Future<bool> toggleRestaurantToBeenList(Restaurant? restaurant);
  Future<bool> addRestaurantToMyLists(
      Restaurant? restaurant, String? listId, bool isAdd);
  Future<bool> addRestaurantToFavouriteList(Restaurant? restaurant, bool isAdd);
  Future<bool?> checkIsInWantToGoList(Restaurant? restaurant);
  Future<bool?> checkIsInBeenList(Restaurant? restaurant);
  Future<bool> checkIsInMyLists(Restaurant? restaurant);
  Future<bool> checkIsInFavouriteList(Restaurant? restaurant);
  Future<ChatMetadata> createChatGroup({List<User?>? users});

  Future<List<Profile>> findProfiles({List<String>? users});
  Future<List<Plan>> findPlans({required String? userId, DateTime? dateFrom});
  Future<List<dynamic>> findReviews({required String? userId});
  Stream<List<RawMessageData>> findLastMessageByChatId({
    required String? chatId,
  });
  Future<List<Plan>> getPlans(DateTime fromDate);
  Future<void> addUserToChatGroup({
    required String? group,
    required String? user,
  });

  Future<List<Restaurant>> findRestaurantsByName({
    required String name,
  });

  Future<Restaurant?> findRestaurant(String? id);
  Future<List<Plan>> findFriendsPlans();

  FollowingsRestaurantReviewsSubscription subscribeFollowingsReviews();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword({
    required String? token,
    required String newPassword,
    Function? onError = null,
  });

  Future<void> sendRestaurant({
    required String? chat,
    required Restaurant restaurant,
  });

  Future<List<User>> findUserByName(String name);
  Future<void> recoverPassword({required String email});

  Future<String?> registerDeviceToken(
      String? deviceToken, String eId, DeviceType platform);
  Future<void> unregisterDeviceToken(String? deviceToken);
  Future<bool?> toggleLikeReview(String? reviewId);
  Future<List<ReviewComment>> getReviewComments(
      String reviewId, int numOfLatest);
  ReviewCommentsSubscription subscribeRestaurantReviewComments(
      String? reviewId);
  Future<ReviewComment> commentReview(String comment, String? reviewId);
}

enum DeviceType { iOS, Android }

class RiceRepositoryImpl implements RiceRepository {
  RiceMeteorService service = RiceMeteorService();
  GooglePlaceService googlePlaceService = GooglePlaceService();
  RiceServerlessService riceServerlessService = RiceServerlessService();

  @override
  Future<String> register(String name, String email) async {
    return service.signUpUser(email, name);
  }

  @override
  Future<Profile> updateProfile(Profile? profile) {
    return service.updateProfile(profile!).then((value) => profile);
  }

  @override
  Future<Profile> updateProfilePicture(File file, {int quality = 100}) async {
    User user = await getCurrentUser();

    String photoUrl =
        await riceServerlessService.uploadProfilePicture(user.id, file);
    Profile profile = user.profile!;
    ProfilePic pic = ProfilePic(url: photoUrl, relative_url: photoUrl);

    Map<String, dynamic> profileJson = profile.toJson();
    profileJson['picture'] = pic.toJson();

    return updateProfile(Profile.fromJson(profileJson));
  }

  Future<Profile> updateProfileAndProfilePicture(
      Profile? profile, File? file) async {
    User user = await getCurrentUser();
    String photoUrl =
        await riceServerlessService.uploadProfilePicture(user.id, file);
    ProfilePic pic = ProfilePic(url: photoUrl, relative_url: photoUrl);

    Map<String, dynamic> profileJson = profile!.toJson();
    profileJson['picture'] = pic.toJson();

    return updateProfile(Profile.fromJson(profileJson));
  }

  @override
  Future<String> login(String? email, String password) {
    return service.login(email!, password);
  }

  @override
  Future<bool> logout() {
    return service.logout().then((novalue) async {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  @override
  Future<bool> isLoggedIn() {
    return service.isLoggedIn().then((novalue) {
      return novalue;
    });
  }

  @override
  Future<User> getCurrentUser() {
    return service.getCurrentUser();
  }

  @override
  String? getCurrentUserId() => service.getCurrentUserId();

  @override
  Future<List<Plan>> findPlans({required String? userId, DateTime? dateFrom}) {
    return service.findPlans(userId, dateFrom);
  }

  @override
  Future<List<Review>> findReviews({
    required String? userId,
  }) {
    return service.findRestaurantReviews(userId);
  }

  @override
  Future<String?> loginWithToken(String? token) {
    return service.loginWithToken(token!);
  }

  @override
  Future<String> loginWithFacebook(FacebookMeta meta) {
    return service.loginWithService(meta);
  }

  @override
  Future<List<Restaurant>> restaurantsInRange(double lat, double lng) async {
    List<Restaurant> restaurants = [];
    restaurants = await service.restaurantsInRange(lat, lng);
    if (restaurants.isEmpty) {
      (await googlePlaceService.searchNearbyWithRadius(lat, lng))
          .forEach((r) async {
        if (r != null) {
          developer.log(
            '${r.toJson().toString()}',
            name: 'restaurantsInRange',
          );
          restaurants.add(await service.storeRestaurant(r));
        }
      });
    }
    return restaurants;
  }

  @override
  Future<List<Restaurant>> restaurantsWithKeyword(
    String keyword,
    double lat,
    double lng,
  ) async {
    List<Restaurant> restaurants = await service.restaurantsWithKeyword(
      keyword,
      lat,
      lng,
    );

    if (restaurants.isEmpty) {
      final googleRestaurants = await googlePlaceService.searchByKeyword(
        keyword,
        lat,
        lng,
      );

      await Future.forEach(googleRestaurants, (dynamic element) async {
        final restaurant = await service.storeRestaurant(element);

        restaurants.add(restaurant);
      });
    }

    return restaurants;
  }

  @override
  Future<List<String>> restaurantPhotos(Restaurant? restaurant) async {
    //return await googlePlaceService.getPlacePhotoUrls(restaurant.googlePlaceId);
    List<Review> reviews = await service.restaurantReviews(restaurant!.id);

    return reviews.expand<String>((review) => review.photos ?? []).toList();
  }

  @override
  Future<List<Review>> restaurantReviews(String? restaurantId) {
    return service.restaurantReviews(restaurantId);
  }

  @override
  Future<ReviewRatings> restaurantOverallRating(Restaurant restaurant) {
    return service.restaurantOverallRating(restaurant.id);
  }

  @override
  Future<Review> reviewRestaurant(Restaurant restaurant, Review review) async {
    return service.reviewRestaurant(restaurant.id, review).then((value) {
      return review;
    });
  }

  @override
  Future<String?> getLocationName(double lat, double lng) {
    return googlePlaceService.fetchPlaceName(lat, lng);
  }

  @override
  Future<List<String>> uploadReviewRestaurantPhotos(
      String? restaurantId, List<XFile> files,
      {int quality = 100}) async {
    return Future.wait(files
        .map((element) => riceServerlessService.uploadRestaurantPicture(
            restaurantId, element))
        .toList());
  }

  @override
  Future<List<Plan>> publicPlansByLocation(double lat, double lng) {
    return service.publicPlansByLocation(lat, lng);
  }

  @override
  Future<List<Plan>> publicPlans(String fromDate) {
    return service.publicPlans(fromDate);
  }

  @override
  Future<String?> createPlan(Plan plan) async {
    return service.createPlan(plan);
  }

  findRestaurant(String? id) {
    return service.findRestaurant(id);
  }

  @override
  Future<List<User?>> getUserFriends(String query) {
    return service.userFriends(query);
  }

  @override
  Future<void> deletePlan(String? id) {
    return service.deletePlan(id);
  }

  @override
  Future<Plan> updatePlan(Plan plan) {
    return service.updatePlan(plan);
  }

  @override
  Future<Plan> fetchPlan(String? id) {
    return service.fetchPlan(id);
  }

  @override
  Future<List<CarouselBanner>> latestPosts() async {
    return service.latestPosts();
  }

  @override
  Future<bool> toggleRestaurantToBeenList(Restaurant? restaurant) async {
    return service.toggleRestaurantBeenToList(restaurant!.id);
  }

  @override
  Future<bool> addRestaurantToFavouriteList(
    Restaurant? restaurant,
    bool isAdd,
  ) async {
    return service.toggleRestaurantFavoriteList(restaurant!.id);
  }

  @override
  Future<bool> addRestaurantToMyLists(
    Restaurant? restaurant,
    String? listId,
    bool isAdd,
  ) async {
    return service.addRestaurantToList(restaurant!, listId);
  }

  @override
  Future<bool> toggleRestaurantWantToGoList(Restaurant? restaurant) async {
    return service.toggleRestaurantWantToGoList(restaurant!.id);
  }

  @override
  Future<bool> checkIsInFavouriteList(Restaurant? restaurant) async {
    return service.checkIsInFavoriteList(restaurant!.id);
  }

  @override
  Future<bool> checkIsInMyLists(Restaurant? restaurant) async {
    return await true;
  }

  @override
  Future<bool?> checkIsInBeenList(Restaurant? restaurant) async {
    return service.checkIsInBeenToList(restaurant!.id);
  }

  @override
  Future<bool?> checkIsInWantToGoList(Restaurant? restaurant) async {
    return service.checkIsInWantToGoList(restaurant!.id);
  }

  ChatListSubscription findChats() {
    return this.service.findChats();
  }

  @override
  Future<List<ChatMessage>> findChatMessages({required String chatId}) {
    return Future.value([]);
  }

  @override
  ChatMessagesSubscription subscribeChatMessages(
      {required String? chatId, int? limit}) {
    return this.service.subscribeChatMessages(
          chatId: chatId,
          limit: limit,
        );
  }

  @override
  Future<SendMessageMetadata> findSendChatMessageRequest(
      {required String chatId}) {
    return this.service.findSendChatMessageRequest(chatId: chatId);
  }

  @override
  Future<List<ChatPartner>> findChatPartners({required String name}) {
    return this.service.findChatPartners(name: name);
  }

  @override
  Future<ChatMetadata> startChat({required User? user}) {
    return this.service.startChat(user: user!);
  }

  @override
  Future<void> sendMessage({
    required String text,
    required ChatMetadata? chat,
  }) {
    return this.service.sendMessage(
          text: text,
          chat: chat,
        );
  }

  @override
  Future<void> sendRestaurant({
    required String? chat,
    required Restaurant restaurant,
  }) {
    return this.service.sendRestaurant(
          chat: chat,
          restaurant: restaurant,
        );
  }

  @override
  Future<void> acceptSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.service.acceptSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  @override
  Future<void> declineSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.service.declineSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  @override
  Future<void> ignoreSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) {
    return this.service.ignoreSendMessageRequest(
          request: request,
          chat: chat,
        );
  }

  Future<Profile> findProfile({
    required String? userId,
  }) async {
    return this.service.findProfile(userId: userId);
  }

  @override
  Future<void> toggleFollowing({
    required String? userId,
  }) async {
    return this.service.toggleFollowing(userId: userId);
  }

  @override
  Future<void> toggleUnfollowing({required String? userId}) {
    return this.service.toggleUnfollowing(userId: userId);
  }

  @override
  Future savePersonalList({
    required CreatePersonalList personalList,
  }) async {
    return this.service.savePersonalList(personalList: personalList);
  }

  @override
  Future<List<ListMetadata>> findPersonalLists({
    required String? userId,
  }) async {
    return this.service.findPersonalLists(userId: userId);
  }

  Future<PersonalList> findPersonalList({required String? listId}) {
    return this.service.findPersonalList(listId: listId);
  }

  Future<List<Plan>> getPlans(DateTime fromDate) async {
    return service.publicPlans(fromDate.toString());
  }

  Future<ChatMetadata> createChatGroup({List<User?>? users}) {
    return this.service.createChatGroup(users: users!);
  }

  Future<List<Profile>> findProfiles({List<String>? users}) {
    return this.service.findProfiles(users: users);
  }

  @override
  Stream<List<RawMessageData>> findLastMessageByChatId(
      {required String? chatId}) {
    return service.findLastMessageByChatId(chatId: chatId);
  }

  @override
  Future<void> addUserToChatGroup({
    required String? group,
    required String? user,
  }) {
    return service.addUserToChatGroup(group: group, user: user);
  }

  @override
  Future<List<Restaurant>> findRestaurantsByName({
    required String name,
  }) {
    return service.findRestaurantsByName(name: name);
  }

  @override
  Future<List<Plan>> findFriendsPlans() {
    return service.findFriendsPlans();
  }

  @override
  FollowingsRestaurantReviewsSubscription subscribeFollowingsReviews() {
    return service.subscribeFollowingsRestaurantReviews();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return service.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> resetPassword({
    required String? token,
    required String newPassword,
    Function? onError = null,
  }) {
    return service.resetPassword(
        token!, newPassword, onError == null ? (err, _) => false : onError);
  }

  @override
  Future<List<User>> findUserByName(String name) {
    return service.findUserByName(name);
  }

  @override
  Future<void> recoverPassword({required String email}) {
    return service.recoverPassword(email: email);
  }

  @override
  Future<String?> registerDeviceToken(
      String? deviceToken, String eId, DeviceType platform) {
    return service.registerDeviceToken(
        token: deviceToken,
        externalId: eId,
        deviceType: (platform == DeviceType.iOS) ? 0 : 1);
  }

  @override
  Future<void> unregisterDeviceToken(String? deviceToken) {
    return service.unregisterDeviceToken(token: deviceToken);
  }

  @override
  Future<bool?> toggleLikeReview(String? reviewId) {
    return service.toggleLikeReview(reviewId);
  }

  @override
  Future<List<ReviewComment>> getReviewComments(
      String reviewId, int numOfLatest) {
    return service.getReviewComments(reviewId, numOfLatest);
  }

  @override
  ReviewCommentsSubscription subscribeRestaurantReviewComments(
      String? reviewId) {
    return service.subscribeRestaurantReviewComments(reviewId);
  }

  @override
  Future<ReviewComment> commentReview(String comment, String? reviewId) {
    return service.commentReview(comment, reviewId);
  }
}
