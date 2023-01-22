import 'dart:io';

import 'package:flutter/foundation.dart';
import 'repository/model/chat.dart';
import 'repository/model/plan.dart';
import 'repository/model/profile.dart';
import 'repository/model/restaurant.dart';
import 'repository/model/review.dart';
import 'repository/model/timeline_reviews.dart';
import 'repository/model/user.dart';

class MainPageArguments {
  static final String tabExplore = 'explore';
  static final String tabPlan = 'plan';
  static final String tabChat = 'chat';
  static final String tabProfile = 'profile';

  final String tab;

  MainPageArguments(this.tab);
}

enum SearchType { KEYWORD, PLACES, PEOPLE }

enum SearchResultViewType { Normal, Map }

abstract class SearchArguments {
  final String name;
  final SearchType type;
  final SearchResultViewType viewType;

  final double lat;
  final double lng;

  SearchArguments(this.name, this.type, this.lat, this.lng,
      {this.viewType = SearchResultViewType.Normal});
}

class KeywordSearchArguments extends SearchArguments {
  final String keyword;
  KeywordSearchArguments(this.keyword, double lat, double lng,
      {SearchResultViewType viewType = SearchResultViewType.Normal})
      : super(keyword, SearchType.KEYWORD, lat, lng, viewType: viewType);
}

class PeopleSearchArguments extends SearchArguments {
  final String keyword;
  PeopleSearchArguments(this.keyword, double lat, double lng,
      {SearchResultViewType viewType = SearchResultViewType.Normal})
      : super(keyword, SearchType.PEOPLE, lat, lng, viewType: viewType);
}

class PlaceSearchArguments extends SearchArguments {
  final String placeName;

  PlaceSearchArguments(this.placeName, double lat, double lng,
      {SearchResultViewType viewType = SearchResultViewType.Normal})
      : super(placeName, SearchType.PLACES, lat, lng, viewType: viewType);
}

class SearchResultPageArguments {
  final SearchArguments arguments;

  SearchResultPageArguments(this.arguments);
}

class RestaursntDetailPageArguments {
  final Restaurant? restaurant;

  RestaursntDetailPageArguments(this.restaurant);
}

class RestaurantListPageArguments {
  final List<Restaurant> restaurants;

  RestaurantListPageArguments(this.restaurants);
}

class PostPageArguments {
  final String postId;

  PostPageArguments(this.postId);
}

class PhotoListPageArguments {
  final List<String>? photos;

  PhotoListPageArguments(this.photos);
}

class ReviewListPageArguments {
  final List<Review> reviews;

  ReviewListPageArguments(this.reviews);
}

class OnBoardingPageArguments {
  final bool isLoggedOut;
  final bool isSignUp;
  final String? signUpToken;
  final String? userId;

  OnBoardingPageArguments(this.isLoggedOut,
      {this.isSignUp = false, this.signUpToken = null, this.userId = null});
}

class ChatRoomPageArguments {
  final int index;
  final ChatMetadata? metadata;

  // Chat room's members except the current user
  final List<Profile?>? profiles;

  ChatRoomPageArguments(
    this.index, {
    this.metadata,
    this.profiles,
  });
}

class RestaurantReviewPageArguments {
  final Restaurant restaurant;

  RestaurantReviewPageArguments(this.restaurant);
}

class CreatePlanPageArguments {
  final Restaurant? restaurant;
  /**
   * Users can come pre-selected from a chat group
   */
  final List<User>? users;
  final Plan? plan;

  CreatePlanPageArguments(
    this.restaurant, {
    this.users = const [],
    this.plan,
  });
}

class ProfilePageArguments {
  final String? userId;

  ProfilePageArguments({required this.userId});
}

class AddCaptionPageArguments {
  final List<File> images;

  AddCaptionPageArguments({
    required this.images,
  });
}

class PersonalListsPageArguments {
  final String? name;
  final String? userId;

  final bool? readonly;

  final Restaurant? restaurant;

  PersonalListsPageArguments({
    this.userId,
    this.restaurant,
    this.name,
    this.readonly,
  });
}

class PersonalRestaurantsPageArguments {
  final String? listId;
  final String? name;
  final List<String>? restaurants;
  final List<String>? mutualRestaurants;
  final String? by;
  final bool? readonly;
  final bool? sharedRestaurantsView;

  PersonalRestaurantsPageArguments(
      {this.listId,
      required this.name,
      this.restaurants,
      this.mutualRestaurants,
      this.by,
      this.readonly,
      this.sharedRestaurantsView});
}

class FollowListPageArguments {
  final FollowListPageArgumentType type;
  final List<String>? userIds;

  FollowListPageArguments({
    required this.type,
    this.userIds,
  });

  String getTypeName() {
    return type.toString().split('.').last;
  }
}

enum FollowListPageArgumentType { Following, Followers }

class FindChatPartnerPageArguments {
  final String? chatId;
  final List<User>? selectedUsers;
  final Restaurant? restaurant;

  FindChatPartnerPageArguments({
    this.chatId,
    this.selectedUsers,
    this.restaurant,
  });
}

class AddGuestsPageArguments {
  final List<User>? users;

  AddGuestsPageArguments({this.users});
}

class ExplorePlansPageArguments {
  final String title;

  ExplorePlansPageArguments({
    required this.title,
  });
}

class ReviewCommentsPageArguments {
  final TimelineReview review;

  ReviewCommentsPageArguments({
    required this.review,
  });
}

class ResetPasswordPageArguments {
  final String? token;

  ResetPasswordPageArguments({
    required this.token,
  });
}

class SignUpPageArguments {
  final String? signUpToken;
  final String? userEmail;

  SignUpPageArguments({this.signUpToken = null, this.userEmail = null});
}
