import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_meteor/dart_meteor.dart';
import '../../environment_config.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import './facebook_service.dart';
import './model/personal_list.dart';
import './model/profile.dart';
import './model/restaurant.dart';
import './model/timeline_reviews.dart';
import '../utils/lru_map.dart';
import 'dart:developer' as developer;

import 'model/editorial.dart';
import 'model/plan.dart';
import 'model/review.dart';
import 'model/review_comment.dart';
import 'model/user.dart';
import 'model/chat.dart';

class RiceMeteorService {
  static final String TAG = "RiceMeteorService";
  static RiceMeteorService _instance = RiceMeteorService._internal();
  static String _riceUrl = EnvironmentConfig.rice_url;

  Function _connectionListener = (ConnectionStatus status) {};

  Function _loggedInListener = (String loggedInUserId) {
    _instance._currentUserId = loggedInUserId;
    _instance._isLoggedIn = loggedInUserId != null;
    developer.log(
        'logged in: ${_instance._isLoggedIn} and user ID: ${_instance._currentUserId} from listener',
        name: TAG);
  };

  Future _holdingConnectionStatus() async {
    ConnectionStatus value = await status!.single;
    switch (value.status) {
      case DdpConnectionStatusValues.connected:
        {
          return;
        }
      case DdpConnectionStatusValues.connecting:
        {
          await for (ConnectionStatus v in status!) {
            if (v.status == DdpConnectionStatusValues.connected) {
              return;
            } else {
              throw StateError('Failed from connecting');
            }
          }
          return;
        }
      default:
        {
          throw StateError('Failed due to state: ${value.status}');
        }
    }
  }

  Stream<ConnectionStatus>? status;

  bool _isLoggedIn = false;
  String? _currentUserId;
  MeteorClient? _meteorClient;

  factory RiceMeteorService() => _instance;
  RiceMeteorService._internal();

  Stream<ConnectionStatus>? connect() {
    if (_meteorClient != null) {
      return status;
    }
    _meteorClient = MeteorClient.connect(url: _riceUrl);
    _meteorClient!.startup(_prepare);
    _meteorClient!
        .userId()
        .listen(_loggedInListener as void Function(String?)?);
    // _meteorClient.userId().listen((loggedInUserId) {
    //   _currentUserId = loggedInUserId;
    //  });
    status = _meteorClient!
        .status()
        .map((event) => ConnectionStatus(event.connected, event.status));

    // status.listen(_connectionListener);

    return status;
  }

  // When Meteor client connected, what needed to be done
  void _prepare() {
    // _meteorClient.prepareCollection('posts');
    // _meteorClient.subscribe('posts', []);
    // _meteorClient.prepareCollection('chats');
    // _meteorClient.subscribe('chats', []);
    // _meteorClient.prepareCollection('groups');
    // _meteorClient.subscribe('groups', []);
    _meteorClient!.userId().listen((userId) {
      _currentUserId = userId;
    });
  }

  Future<void> disconnect() async {
    if (_meteorClient != null) {
      _meteorClient!.disconnect();
      _meteorClient = null;
    }
  }

  Future<void> pause() async {
    developer.log('Pausing service', name: TAG);
    if (_meteorClient != null) {
      // await logout();
      // developer.log('Logged out user', name: 'RiceMeteorService');
      await disconnect();
      developer.log('Paused service', name: TAG);
    }
  }

  Future<String?> resume({required String? token}) async {
    developer.log('Resuming service', name: TAG);
    await connect();
    developer.log('service connected', name: TAG);
    if (_meteorClient != null && token != null) {
      String? resultToken = await loginWithToken(token);
      developer.log('Logged in user', name: TAG);
      return resultToken;
    }
    return null;
  }

  Future<String> createUser(String email, String password, String name) async {
    return _meteorClient!
        .call('users.create', args: [email, password, name]).then((value) {
      return value;
    });
  }

  Future<String> signUpUser(String email, String name) async {
    return _meteorClient!
        .call('users.signup', args: [email, name]).then((value) {
      return value;
    });
  }

  Future<void> updateProfile(Profile profile) async {
    return _meteorClient!.call('updateProfile', args: [
      {
        'name': profile.name,
        'bio': profile.bio,
        'favoriteFood': profile.favoriteFood,
        'cantEatFood': profile.cantEatFood,
        'location': profile.location,
        'languages': profile.languages,
        'picture': profile.picture,
      }
    ]);
  }

  Future<String> login(String email, String password) async {
    return _meteorClient!
        .loginWithPassword(email, password)
        .then((value) async {
      _currentUserId = value.userId;
      ;
      return value.token;
    });
  }

  Future<String?> loginWithToken(String token) async {
    try {
      developer.log('Starting login attempt', name: TAG);
      final value = await (_meteorClient!.loginWithToken(
          token: token,
          tokenExpires: DateTime.now().add(Duration(days: 90)) // 3 months
          ) as FutureOr<MeteorClientLoginResult>);

      developer.log('Login value: ${value}', name: TAG);

      _currentUserId = value.userId;

      return value.token;
    } catch (error) {
      developer.log('Login error $error', name: TAG);

      return null;
    }
  }

  Future<String> loginWithService(FacebookMeta option,
      {String service = 'facebook'}) async {
    // await _holdingConnectionStatus();
    return _meteorClient!.call('login', args: [option.toJson()]).then((result) {
      Credential credential = Credential.fromJson(result);
      _currentUserId = credential.id;
      return credential.token!;
    });
  }

  Future<User> getCurrentUser() async {
    if (_currentUserId == null) {
      developer.log(
          'Current user id not found, ${_meteorClient!.userIdCurrentValue()}',
          name: TAG);
      throw AssertionError("Current user is not existed");
    }
    return _meteorClient!
        .call('users.find.one', args: [_currentUserId]).then((result) {
      return User.fromJson(result);
    });
  }

  String? getCurrentUserId() => _currentUserId;

  Future<void> logout() async {
    if (_meteorClient == null) return;
    return Future(() => _meteorClient!.logout()).then((value) {
      _currentUserId = null;
    });
  }

  Future<bool> isLoggedIn() {
    return Future.value(_meteorClient != null && _isLoggedIn);
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    return _meteorClient!
        .changePassword(oldPassword, newPassword)
        .then((result) => true);
  }

  Future<bool> resetPassword(
      String token, String newPassword, Function onError) async {
    return _meteorClient!
        .resetPassword(token, newPassword)
        .then((result) => true)
        .catchError(onError);
  }

  Future<List<Restaurant>> restaurantsInRange(double lat, double lng) async {
    return _meteorClient!
        .call('restaurantsInRange', args: [lat, lng, 10, 0]).then((results) {
      List<Restaurant> restaurants = (results as List<dynamic>)
          .map((r) => Restaurant.fromJson(r))
          .toList();
      // developer.log(restaurants, name: TAG);
      return restaurants;
    });
  }

  Future<List<Restaurant>> restaurantsWithKeyword(
    String keyword,
    double lat,
    double lng,
  ) async {
    final results = await _meteorClient!.call('restaurantsInRange', args: [
      lat,
      lng,
    ]);

    List<Restaurant> restaurants = (results as List<dynamic>)
        .map((r) => Restaurant.fromJson(r))
        .where((r) => r.name!.contains(keyword))
        .toList();

    return restaurants;
  }

  Future<List<Review>> restaurantReviews(String? restaurantId) async {
    return _meteorClient!
        .call('getRestaurantReviews', args: [restaurantId]).then((results) {
      if (results != null) {
        List<Review> reviews =
            (results as List<dynamic>).map((r) => Review.fromJson(r)).toList();
        // developer.log(restaurants, name: TAG);
        return reviews;
      }
      return [];
    });
  }

  Future<List<Plan>> planInRange(double lat, double lng) async {
    return _meteorClient!
        .call('plan.findByLocation', args: [lat, lng]).then((results) {
      List<Plan> plans =
          (results as List<dynamic>).map((r) => Plan.fromJson(r)).toList();
      // developer.log(restaurants, name: TAG);
      return plans;
    });
  }

  Future<List<Plan>> publicPlans(String fromDate) async {
    final data = await _meteorClient!.call(
      'profile.plans.find',
      args: [fromDate],
    );

    developer.log('Public plans ${data}', name: TAG);

    List<Plan> plans = List.of(data).map((p) => Plan.fromJson(p)).toList();

    return plans;
  }

  Future<List<Plan>> publicPlansByLocation(double lat, double long) async {
    final plans = await _meteorClient!.call(
      'quickplan.findByLocation',
      args: [lat, long],
    );

    final upcomingPlans =
        await _meteorClient!.call('profile.plans.find', args: [
      _currentUserId,
      {"\$date": DateTime.now().millisecondsSinceEpoch}
    ]);

    return List.of(upcomingPlans).map((e) => Plan.fromJson(e)).toList();
  }

  Future<String?> createPlan(Plan plan) async {
    final result =
        await _meteorClient!.call('plan.save', args: [plan.toJson()]);

    return result;
  }

  Future<Restaurant?> findRestaurant(String? id) async {
    final result = await _meteorClient!.call('getRestaurantById', args: [id]);

    // developer.log('Find restaurant: ${result}', name: TAG);

    if (result == null) {
      return null;
    }

    return Restaurant.fromJson(result);
  }

  Future<List<User?>> userFriends(String query) async {
    return _meteorClient!.call('users.find', args: [query]).then((results) {
      if (results != null) {
        List<User?> friends = (results as List<dynamic>).map((p) {
          if (p != null) {
            return User.fromJson(p);
          }
          return null;
        }).toList();
        return friends;
      }
      return [];
    });
  }

  Future<void> deletePlan(String? id) async {
    await _meteorClient!.call('plan.delete', args: [id]);
  }

  Future<Plan> updatePlan(Plan plan) async {
    // developer.log('Update plan: ${plan.toJson()}', name: TAG);

    return _meteorClient!
        .call('plan.update', args: [plan.toJson()]).then((result) {
      // Plan plan = Plan.fromJson(result);
      return plan;
    });
  }

  Future<Restaurant> storeRestaurant(Restaurant restaurant) async {
    final data = {
      'name': restaurant.name,
      'address': restaurant.address,
      'googlePlaceId': restaurant.googlePlaceId,
      'location': restaurant.location!.toJson(),
    };

    if (restaurant.photo != null) {
      data['photo'] = restaurant.photo;
    }

    final openingHoursDetail =
        List.of(restaurant.openingHoursDetail!.toJson()['periods']);

    if (openingHoursDetail.isNotEmpty) {
      data['openingHoursDetail'] = openingHoursDetail;
    }

    final result = await _meteorClient!.call(
      'addRestaurant',
      args: [data],
    );

    // developer.log('Add restaurant result: $result', name: TAG);

    // if (Restaurant.fromJson(result).googlePlaceId != restaurant.googlePlaceId) {
    //   throw StateError('The result is not the same as stored one');
    // }
    // developer.log(restaurant.toString());
    return Restaurant.fromJson(result);
  }

  Future<ReviewRatings> restaurantOverallRating(String? restaurantId) async {
    return _meteorClient!.call('getRestaurantOverallRatings',
        args: [restaurantId]).then((result) {
      if (result != null) {
        ReviewRatings ratings = ReviewRatings.fromJson(result);
        developer.log(ratings.toString(), name: TAG);
        return ratings;
      }

      return ReviewRatings();
    });
  }

  Future<void> reviewRestaurant(String? restaurantId, Review review) async {
    if (review.photos == null) {
      review.photos = [];
    }
    var reviewJson = review.toJson();
    return _meteorClient!.call('reviewRestaurant',
        args: [reviewJson, restaurantId]).then((result) {
      // ReviewRatings ratings = ReviewRatings.fromJson(result);
      developer.log('Posted review', name: TAG);
      // return ratings;
    });
  }

  Future<List<CarouselBanner>> latestPosts() async {
    final editorials =
        await _meteorClient!.call('editorials.findAll', args: []);

    return [];
  }

  ChatListSubscription findChats() {
    // final user = await this.getCurrentUser();
    // _meteorClient.prepareCollection('chats');
    // _meteorClient.prepareCollection('messages');

    // the second parameter is the count of chunk message are getting. (A chunk message size is 30)
    // Here subscribe will firstly get the amount of messages and then listening the new message
    var handler = _meteorClient!.subscribe('chats', args: []);
    // _meteorClient.collections['chats']
    final chats = _meteorClient!.collection('chats').map<List<ChatMetadata>>(
      (collection) {
        return collection.entries.map(
          (entry) {
            return ChatMetadata(
              id: entry.value['_id'] as String?,
              members: List.of(entry.value['memberIds'])
                  .map<String>((e) => e.toString())
                  .where((id) => id != _currentUserId)
                  .toList(),
            );
          },
        ).toList();
      },
    );

    return ChatListSubscription(
      handler: handler,
      chats: chats,
      lastMessages: _meteorClient!.collection('messages').map((raw) => raw
          .map((key, value) => MapEntry(key, RawMessageData.fromJson(value)))),
      users:
          _meteorClient!.collection('users').map((raw) => raw.map((key, value) {
                value['profile']['userId'] = key;
                return MapEntry(
                    key,
                    User(
                        id: key,
                        username: null,
                        emails:
                            null, //List.from(value['emails']).map((e) => Email.fromJson(e)).toList(),
                        profile: Profile.fromJson(value['profile'])));
              })),
      connectionStatus: status,
    );
  }

  Future<List<Plan>> findPlans(String? userId, DateTime? fromDate) async {
    final plans = await _meteorClient!.call('profile.plans.find', args: [
      userId,
      {"\$date": DateTime.now().millisecondsSinceEpoch}
    ]);

    // developer.log('Plans by profile ${plans} ', name: TAG);

    return List.of(plans).map((e) => Plan.fromJson(e)).toList();
  }

  Future<Plan> fetchPlan(String? planId) async {
    final plan = await _meteorClient!.call('plan.find.one', args: [planId]);
    // developer.log('Fetch Plans by ID ${plan}', name: TAG);
    return Plan.fromJson(plan);
  }

  Future<List<Plan>> findFriendsPlans() async {
    return [];
  }

  Future<List<Review>> findRestaurantReviews(String? userId) async {
    final reviews =
        await _meteorClient!.call('getMyRestaurantReviews', args: []);

    return List.of(reviews).map((e) => Review.fromJson(e)).toList();
  }

  Future<SendMessageMetadata> findSendChatMessageRequest({
    required String chatId,
  }) {
    return Future.delayed(Duration(seconds: 2)).then((value) {
      return SendMessageMetadata(
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        createdBy: null,
        description: 'Has requested to join your plan',
      );
    });
  }

  ChatMessagesSubscription subscribeChatMessages({
    required String? chatId,
    int? limit,
  }) {
    // final user = await this.getCurrentUser();
    // _meteorClient.prepareCollection('messages');

    // the second parameter is the count of chunk message are getting. (A chunk message size is 30)
    // Here subscribe will firstly get the amount of messages and then listening the new message
    var handler = _meteorClient!.subscribe('messages', args: [chatId]);

    return ChatMessagesSubscription(
      chatId: chatId,
      handler: handler,
      collection: _meteorClient!.collection('messages'),
      connectionStatus: status,
    );
  }

  Stream<List<RawMessageData>> findLastMessageByChatId({
    required String? chatId,
  }) {
    // _meteorClient.prepareCollection('messages');

    final controller = StreamController<List<RawMessageData>>();

    _meteorClient!.collection('messages').map(
      (event) {
        if (event.entries == null) return [];

        return event.entries
            .map((e) => RawMessageData.fromJson(e.value))
            .toList();
      },
    ).listen((event) {
      controller.add(event as List<RawMessageData>);
    });

    return controller.stream;
  }

  Future<List<ChatPartner>> findChatPartners({
    required String name,
  }) {
    if (name.isEmpty) return Future.value([]);

    return _meteorClient!.call('users.find', args: [name]).then((value) {
      return (value as List<dynamic>)
          .where((element) => element['profile'] != null)
          .map<ChatPartner>(
        (user) {
          return ChatPartner(
            user: User.fromJson(user),
            chat: null,
          );
        },
      ).toList();
    });
  }

  Future<List<User>> findUserByName(String name) async {
    final data = await _meteorClient!.call('users.find', args: [name]);

    return List.of(data).map((e) => User.fromJson(e)).toList();
  }

  Future<ChatMetadata> startChat({
    required User user,
  }) async {
    return _meteorClient!.call('startChat', args: [user.id]).then(
      (value) => ChatMetadata(
        id: value['_id'],
        name: user.profile!.name,
        members: [user.id],
      ),
    );
  }

  Future<void> sendMessage({
    required String text,
    required ChatMetadata? chat,
  }) async {
    // send a text type of message to Chat with chat ID
    if (text.isEmpty) {
      return;
    }

    _meteorClient!.call("addMessage", args: ['text', chat!.id, text]);
  }

  Future<void> sendRestaurant({
    required String? chat,
    required Restaurant restaurant,
  }) async {
    await _meteorClient!.call(
      "addMessage",
      args: [
        'location',
        chat,
        restaurant.id,
      ],
    );
  }

  Future<Profile> findProfile({required String? userId}) async {
    return _meteorClient!.call('findProfileByIds', args: [
      [userId]
    ]).then((result) async {
      final profile = result[0]['profile'];

      profile['userId'] = userId;

      final data = Profile.fromJson(profile);

      // developer.log('Profile data: $profile', name: TAG);

      final upcomingPlans =
          await _meteorClient!.call('profile.plans.find', args: [
        userId,
        {"\$date": DateTime.now().millisecondsSinceEpoch}
      ]);

      // developer.log('Upcoming plans $upcomingPlans', name: TAG);

      data.upcomingPlans =
          List.of(upcomingPlans).map((e) => Plan.fromJson(e)).toList();

      final reviews = await _meteorClient!.call(
        'getUserRestaurantReviews',
        args: [userId],
      );

      // developer.log('User Reviews: $reviews', name: TAG);

      data.photos = List.of(reviews)
          .map((e) => Review.fromJson(e))
          .expand<String>((e) => e.photos ?? [])
          .toList();

      final favorites = await _meteorClient!.call(
        'list.find.favorite',
        args: [userId],
      );

      final restaurantIds = List.of(favorites).expand((list) {
        return List.of(list['items'] ?? []).map<String?>(
          (e) => e['restaurantId'],
        );
      }).toList();

      if (List.of(favorites).isNotEmpty) {
        data.favoriteListId = favorites[0]['_id'];
      }

      // developer.log('Restaurant ids: $restaurantIds', name: TAG);

      data.favorites = [];

      await Future.forEach(restaurantIds, (dynamic id) async {
        final restaurant =
            await _meteorClient!.call('getRestaurantById', args: [id]);

        data.favorites!.add(Restaurant.fromJson(restaurant));
      });

      final personalLists =
          await _meteorClient!.call('lists.find.all', args: [userId]);

      // developer.log('Personal lists $personalLists', name: TAG);

      data.lists = List.of(personalLists)
          .where((element) =>
              element['isFavorite'] != null ? !element['isFavorite'] : false)
          .map((e) => ListMetadata.fromJson(e))
          .toList();

      return data;
    });
  }

  Future<bool> addRestaurantToList(
    Restaurant restaurant,
    String? listId,
  ) async {
    await _meteorClient!.call(
      'lists.restaurants.add',
      args: [listId, restaurant.id, 'like this restaurant'],
    );

    return true;
  }

  Future<void> toggleFollowing({required String? userId}) async {
    await _meteorClient!.call('users.follow', args: [userId]);
  }

  Future<void> toggleUnfollowing({required String? userId}) async {
    await _meteorClient!.call('users.unfollow', args: [userId]);
  }

  Future<List<ListMetadata>> findPersonalLists(
      {required String? userId}) async {
    final personalLists =
        await _meteorClient!.call('lists.find.all', args: [userId]);

    return List.of(personalLists)
        .where((e) => !e['isFavorite'])
        .map((e) => ListMetadata.fromJson(e))
        .toList();
  }

  Future<PersonalList> findPersonalList({required String? listId}) async {
    final personalList =
        await _meteorClient!.call('lists.find.one', args: [listId]);

    final profile = await this.findProfile(userId: personalList['userId']);

    return PersonalList(
      name: personalList['name'],
      createdBy: User(
        id: profile.userId,
        username: '',
        profile: profile,
        emails: [],
      ),
      restaurants: List.of(personalList['items'] ?? [])
          .map((e) => Restaurant.fromJson(e['restaurant']))
          .toList(),
    );
  }

  Future<List<ListMetadata>> savePersonalList({
    required CreatePersonalList personalList,
  }) async {
    final result = await _meteorClient!.call('lists.save', args: [
      {
        'name': personalList.name,
        'shortDescription': personalList.name,
        'isPublic': true,
        'isFavorite': false
      },
    ]);

    // developer.log('Create personal list result $result', name: TAG);

    return [];
  }

  Future<void> acceptSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) async {
    await Future.delayed(
      Duration(seconds: 2),
    );
  }

  Future<void> declineSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) async {
    await Future.delayed(
      Duration(seconds: 2),
    );
  }

  Future<void> ignoreSendMessageRequest({
    required SendMessageMetadata request,
    required ChatMetadata chat,
  }) async {
    await Future.delayed(
      Duration(seconds: 2),
    );
  }

  Future<ChatMetadata> createChatGroup({required List<User?> users}) async {
    final title = users.map((user) => user!.profile!.name).join(', ');

    final picture =
        'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png';

    final data = {
      'userId': _currentUserId,
      'users': users
          .map((e) => {
                '_id': e!.id,
                'username': e.emails![0].address,
                'profile': e.profile
              })
          .toList(),
      'title': title,
      'photo': picture,
      'dateCreated': {"\$date": DateTime.now().millisecondsSinceEpoch},
    };

    final result = await _meteorClient!.call('groups.insert', args: [data]);

    return ChatMetadata(
      id: result['chatId'] as String?,
      name: users.map((e) => e!.profile!.name).join(', '),
      members: users.map((e) => e!.id).toList(),
    );
  }

  Future<List<Profile>> findProfiles({List<String>? users}) async {
    final profiles =
        await _meteorClient!.call('findProfileByIds', args: [users]);

    return List.of(profiles).map((e) {
      e['profile']['userId'] = e['_id'];

      return Profile.fromJson(e['profile']);
    }).toList();
  }

  Future<void> addUserToChatGroup({
    required String? group,
    required String? user,
  }) async {
    await _meteorClient!.call('groups.add.user', args: [
      {'groupId': group, 'userId': user}
    ]);
  }

  Future<List<Restaurant>> findRestaurantsByName({
    required String name,
  }) async {
    final results =
        await _meteorClient!.call('restaurantsTopRatedInRange', args: [
      {'lat': -19.8330587, 'lng': -43.9773101, 'limit': 10, 'skip': 0}
    ]);

    return [];
  }

  Future<bool?> checkIsInWantToGoList(String? restaurantId) async {
    var result = await _meteorClient!.call('checkWantTo', args: [restaurantId]);
    return jsonDecode(result.toString());
  }

  Future<bool?> checkIsInBeenToList(String? restaurantId) async {
    var result = await _meteorClient!.call('checkBeenTo', args: [restaurantId]);
    return jsonDecode(result.toString());
  }

  Future<bool> checkIsInFavoriteList(String? restaurantId) async {
    final favoriteList = await this.findFavoriteList();

    final isInFavorites = List.of(favoriteList['items'] ?? [])
        .where((element) => element['restaurantId'] == restaurantId)
        .toList()
        .isNotEmpty;

    // developer.log('Is in favorites? ${isInFavorites}', name: TAG);

    return isInFavorites;
  }

  Future<bool> toggleRestaurantWantToGoList(String? restaurantId) async {
    return _meteorClient!
        .call('toggleWantTo', args: [restaurantId]).then((result) {
      if (result != null) {
        bool isAdd = jsonDecode(result.toString());
        // developer.log(isAdd.toString(), name: TAG);
        return isAdd;
      } else
        throw Exception();
    });
  }

  Future<bool> toggleRestaurantBeenToList(String? restaurantId) async {
    return _meteorClient!
        .call('toggleBeenTo', args: [restaurantId]).then((result) {
      if (result != null) {
        bool isAdd = jsonDecode(result.toString());
        // developer.log(isAdd.toString(), name: TAG);
        return isAdd;
      } else
        throw Exception();
    });
  }

  Future<dynamic> findFavoriteList() async {
    final favoriteLists = await _meteorClient!.call(
      'list.find.favorite',
      args: [_currentUserId],
    );

    // developer.log('Favorite lists: ${favoriteLists}', name: TAG);

    dynamic favoriteList;

    if (List.of(favoriteLists).isEmpty) {
      await _meteorClient!.call('lists.save', args: [
        {
          'name': 'Favorites',
          'shortDescription': 'Favorite restaurants',
          'isPublic': true,
          'isFavorite': true
        },
      ]);

      favoriteList = await this.findFavoriteList();
    } else {
      favoriteList = favoriteLists[0];
    }

    return favoriteList;
  }

  Future<bool> toggleRestaurantFavoriteList(String? restaurantId) async {
    final favoriteList = await this.findFavoriteList();

    final isRestaurantedAdded = List.of(favoriteList['items'] ?? [])
        .where((element) => element['restaurantId'] == restaurantId)
        .toList()
        .isNotEmpty;

    if (!isRestaurantedAdded) {
      await _meteorClient!.call(
        'lists.restaurants.add',
        args: [favoriteList['_id'], restaurantId, 'I like this restaurant'],
      );

      return true;
    } else {
      await _meteorClient!.call(
        'lists.restaurants.remove',
        args: [favoriteList['_id'], restaurantId],
      );

      return false;
    }
  }

  Future<void> recoverPassword({required String email}) async {
    await _meteorClient!.forgotPassword(email);
  }

  Future<String?> registerDeviceToken(
      {required String? token,
      required int deviceType,
      String? externalId}) async {
    return await (_meteorClient!.call('user.registerToken',
        args: [token, deviceType]) as FutureOr<String?>);
  }

  Future<void> unregisterDeviceToken({required String? token}) async {
    await _meteorClient!.call('user.unregisterToken', args: [token]);
  }

  FollowingsRestaurantReviewsSubscription
      subscribeFollowingsRestaurantReviews() {
    // _meteorClient.prepareCollection('user_reviews');
    // _meteorClient.prepareCollection('users');
    // _meteorClient.prepareCollection('restaurants');

    var handler = _meteorClient!.subscribe('user_reviews',
        args: [FollowingsRestaurantReviewsSubscription.PAGE_SIZE, 1]);

    return FollowingsRestaurantReviewsSubscription(
      handler: handler,
      connectionStatus: status,
      meteorClient: _meteorClient,
      currentUserId: getCurrentUserId(),
    );
  }

  Future<List<ReviewComment>> getReviewComments(
      String reviewId, int numOfLatest) async {
    var comments = await _meteorClient!
        .call('getReviewComments', args: [reviewId, numOfLatest]);
    return List.of(comments).map((e) {
      return ReviewComment.fromJson(e);
    }).toList();
  }

  Future<ReviewComment> commentReview(String comment, String? reviewId) {
    return _meteorClient!.call('commentReview', args: [comment, reviewId]).then(
        (value) => ReviewComment.fromJson(value));
  }

  ReviewCommentsSubscription subscribeRestaurantReviewComments(
      String? reviewId) {
    // _meteorClient.prepareCollection('review_comments');
    // _meteorClient.prepareCollection('users');

    var handler = _meteorClient!.subscribe('review_comments', args: [reviewId]);
    final comments =
        _meteorClient!.collection('review_comments').map<List<ReviewComment>>(
      (collection) {
        return collection.entries.map(
          (entry) {
            entry.value['_id'] = entry.key ?? entry.value['_id'];
            return ReviewComment.fromJson(entry.value);
          },
        ).toList();
      },
    );
    return ReviewCommentsSubscription(
      handler: handler,
      comments: comments,
      connectionStatus: status,
      meteorClient: _meteorClient,
    );
  }

  Future<bool?> toggleLikeReview(String? reviewId) async {
    return await (_meteorClient!.call('toggleLikeReview', args: [reviewId])
        as FutureOr<bool?>);
  }
}

abstract class Subscription {
  final Stream<ConnectionStatus>? connectionStatus;

  Subscription(this.connectionStatus);
  void unsubscribe();
}

class FollowingsRestaurantReviewsSubscription extends Subscription {
  static final int MAX_PAGE = 10;
  static final int PAGE_SIZE = 10;
  SubscriptionHandler? _handler;
  MeteorClient? _meteorClient;
  String? _currentUserId;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int get pageSize => PAGE_SIZE;

  StreamController<List<TimelineReview>> _controller =
      StreamController<List<TimelineReview>>.broadcast();

  Map<String, TimelineReview> _cachedUserReviewCollections = {};
  LruMap<String?, User> _cachedUserCollections = LruMap();
  LruMap<String?, Restaurant> _cachedRestaurantCollections = LruMap();

  FollowingsRestaurantReviewsSubscription({
    required SubscriptionHandler handler,
    required Stream<ConnectionStatus>? connectionStatus,
    required MeteorClient? meteorClient,
    required String? currentUserId,
  }) : super(connectionStatus) {
    this._meteorClient = meteorClient;

    _meteorClient!.collection('user_reviews').listen(_userReviewListener);
    _meteorClient!.collection('restaurants').listen(_restaurantListener);
    _meteorClient!.collection('users').listen(_userListener);
    _currentUserId = currentUserId;
  }

  void _userReviewListener(Map<String, dynamic> reviews) {
    if (reviews != null && reviews.isNotEmpty) {
      reviews.entries.forEach((element) {
        if (element.value != null && element.key != null) {
          String id = element.key;
          element.value['_id'] = id;
          var review = Review.fromJson(element.value);

          var user = _cachedUserCollections[review.userId];
          review.userName = user?.profile?.name ?? '';
          review.userPhoto = user?.profile?.picture?.url ?? '';

          var restaurant = _cachedRestaurantCollections[review.restaurantId];

          if (_cachedUserReviewCollections.containsKey(id)) {
            TimelineReview timelineReview = _cachedUserReviewCollections[id]!;
            Review? r = timelineReview.review;

            if (review.likes != null) {
              r!.likes = review.likes;
            }
          } else {
            var timelineReview = TimelineReview(
              review: review,
              user: user,
              restaurant: restaurant,
              currentUserId: _currentUserId,
            );
            _cachedUserReviewCollections[id] = timelineReview;
            List<TimelineReview> list = _cachedUserReviewCollections.values
                .toList()
              ..sort((TimelineReview a, TimelineReview b) =>
                  b.review!.dateCreated!.compareTo(a.review!.dateCreated!));
            developer.log("reviews.length = ${list.length}",
                name: "ExploreScreenState");
            _controller.add(list);
          }
        }
      });
    }
  }

  void _userListener(Map<String, dynamic> users) {
    if (users != null && users.isNotEmpty) {
      users.entries.forEach((element) {
        if (element.value != null && element.key != null) {
          String id = element.key;
          User u = User.fromJson(element.value);
          developer.log("added user ${id} - $u", name: "ExploreScreenState");
          _cachedUserCollections[u.id] = User.fromJson(element.value);
        }
      });
    }
  }

  void _restaurantListener(Map<String, dynamic> restaurants) {
    if (restaurants != null && restaurants.isNotEmpty) {
      restaurants.entries.forEach((element) {
        if (element.value != null && element.key != null) {
          String id = element.key;
          Restaurant r = Restaurant.fromJson(element.value);
          developer.log("added restaurant ${id} - $r",
              name: "ExploreScreenState");
          _cachedRestaurantCollections[r.id] =
              Restaurant.fromJson(element.value);
        }
      });
    }
  }

  void nextPage() {
    if (_currentPage < MAX_PAGE) {
      developer.log("nextPage called ${_currentPage + 1}",
          name: "ExploreScreenState");
      _handler = _meteorClient!
          .subscribe('user_reviews', args: [++_currentPage, PAGE_SIZE]);
    }
  }

  void lastPage() {
    if (_currentPage > 0) {
      developer.log("lastPage called ${_currentPage - 1}",
          name: "ExploreScreenState");
      _handler = _meteorClient!
          .subscribe('user_reviews', args: [--_currentPage, PAGE_SIZE]);
    }
  }

  Future<Profile> _findProfileById(String? id) {
    return _meteorClient!.call('findProfileByIds', args: [
      [id]
    ]).then((result) async {
      final profile = result[0]['profile'];

      profile['userId'] = id;

      return Profile.fromJson(profile);
    });
  }

  Future<List<ReviewCommentWithUser>> _getReviewComments(
      String? reviewId, int numOfLatest) async {
    var comments = await _meteorClient!
        .call('getReviewComments', args: [reviewId, numOfLatest]);

    var list = List.of(comments).map((e) {
      // Profile profile = await _findProfileById(e.id);
      ReviewComment c = ReviewComment.fromJson(e);
      return ReviewCommentWithUser(
        null,
        id: c.id,
        userReviewId: c.userReviewId,
        userId: c.userId,
        comment: c.comment,
        dateCreated: c.dateCreated,
      );
    }).toList();

    await Future.forEach<ReviewCommentWithUser>(list, (element) async {
      if (_cachedUserCollections.containsKey(element.userId)) {
        element.user = _cachedUserCollections[element.userId];
      } else {
        User user = await _findProfileById(element.userId).then((value) => User(
            id: element.userId, username: null, emails: null, profile: value));
        _cachedUserCollections[element.userId] = user;
        element.user = user;
      }
      return element;
    });

    return list;
  }

  Stream<List<TimelineReview>> getReviews() {
    return _controller.stream.map((event) {
      event.forEach((element) {
        element.futureReviewComments =
            _getReviewComments(element.review!.id, 3);
      });
      return event;
    });
  }

  @override
  void unsubscribe() {
    if (_handler != null) {
      _handler!.stop();
    }
    _controller.close();
  }
}

class ChatListSubscription extends Subscription {
  SubscriptionHandler? _handler;
  late Stream<List<ChatMetadata>> _chats;
  late Stream<Map<String, RawMessageData>> _lastMessages;
  late Stream<Map<String, User>> _users;

  ChatListSubscription({
    required SubscriptionHandler handler,
    required Stream<List<ChatMetadata>> chats,
    required Stream<Map<String, RawMessageData>> lastMessages,
    required Stream<Map<String, User>> users,
    required Stream<ConnectionStatus>? connectionStatus,
  }) : super(connectionStatus) {
    this._handler = handler;
    this._chats = chats;
    this._lastMessages = lastMessages;
    this._users = users;
  }

  Stream<List<ChatMetadata>> chats() {
    return _chats.map((chat) {
      chat.forEach((c) {
        // Collect last message
        _lastMessages.forEach((messages) {
          c.lastMessage = messages.values.lastWhereOrNull(
            (element) => element.chatId == c.id,
          );
        });

        // Collect member profiles
        _users.forEach((users) {
          c.members!.forEach((memberId) {
            if (users.containsKey(memberId)) {
              if (c.users == null) {
                c.users = {};
              }

              c.users![memberId] = users[memberId!];
            }
          });
        });
      });
      return chat;
    });
  }

  @override
  void unsubscribe() {
    if (_handler != null) {
      _handler!.stop();
    }
  }
}

class ChatMessagesSubscription extends Subscription {
  final String? chatId;
  SubscriptionHandler? _handler;
  late Stream<List<RawMessageData>> _messages;

  ChatMessagesSubscription({
    required SubscriptionHandler handler,
    required Stream<Map<String, dynamic>> collection,
    this.chatId,
    required Stream<ConnectionStatus>? connectionStatus,
  }) : super(connectionStatus) {
    this._handler = handler;
    this._messages = collection.map(
      (raw) {
        final data = raw.entries
            .map((entry) {
              return RawMessageData.fromJson(entry.value);
            })
            .where((element) => element.chatId == chatId)
            .toList();

        data.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return data;
      },
    );
  }

  Stream<List<ChatMessage>> messages() => _messages.map((rawMessageData) {
        return rawMessageData
            .map(
              (e) => ChatMessage(
                id: e.id,
                message: e.content,
                createdAt: e.createdAt,
                senderId: e.senderId,
                type: e.type,
              ),
            )
            .toList();
      });

  @override
  void unsubscribe() {
    if (_handler != null) {
      _handler!.stop();
    }
  }
}

class ReviewCommentsSubscription extends Subscription {
  SubscriptionHandler? _handler;
  late Stream<List<ReviewComment>> _comments;
  MeteorClient? _meteorClient;

  LruMap<String?, User> _cachedUserCollections = LruMap();

  ReviewCommentsSubscription({
    required SubscriptionHandler handler,
    required Stream<List<ReviewComment>> comments,
    required Stream<ConnectionStatus>? connectionStatus,
    required MeteorClient? meteorClient,
  }) : super(connectionStatus) {
    this._handler = handler;
    this._comments = comments;
    this._meteorClient = meteorClient;

    _meteorClient!.collection('users').listen(_userListener);
  }

  void _userListener(Map<String, dynamic> users) {
    if (users != null && users.isNotEmpty) {
      users.entries.forEach((element) {
        if (element.value != null && element.key != null) {
          User u = User.fromJson(element.value);
          _cachedUserCollections[u.id] = User.fromJson(element.value);
        }
      });
    }
  }

  Stream<List<ReviewCommentWithUser>> comments() {
    return _comments.map((comments) {
      return comments.map((c) {
        ReviewCommentWithUser r = ReviewCommentWithUser(
            _cachedUserCollections[c.userId],
            id: c.id,
            userReviewId: c.userReviewId,
            userId: c.userId,
            comment: c.comment,
            dateCreated: c.dateCreated);
        return r;
      }).toList();
    });
  }

  @override
  void unsubscribe() {
    if (_handler != null) {
      _handler!.stop();
    }
  }
}

class ConnectionStatus {
  bool connected;
  DdpConnectionStatusValues status;
  ConnectionStatus(this.connected, this.status);
}
