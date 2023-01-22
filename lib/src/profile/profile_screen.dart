import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import '../base_bloc.dart';
import 'package:rice/src/chat_room/chat_room_page.dart';
import 'package:rice/src/explore_plans/explore_plans_page.dart';
import 'package:rice/src/follow_list/follow_list_page.dart';
import 'package:rice/src/onboarding/index.dart';
import 'package:rice/src/photo_list/index.dart';
import 'package:rice/src/plan_detail/index.dart';
import 'package:rice/src/profile/index.dart';
import '../repository/model/plan.dart';
import '../repository/model/profile.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import 'package:rice/src/restaurant_detail/index.dart';
import 'package:rice/src/notification/index.dart';
import 'package:rice/src/settings/index.dart';
import 'package:rice/src/view/avatar_row.dart';
import 'package:rice/src/create_plan/create_plan_page.dart';
import 'package:rice/src/screen_arguments.dart';
import 'package:rice/src/view/gallery_photo_view.dart';
import 'package:rice/src/personal_lists/personal_lists_page.dart';
import 'package:rice/src/personal_restaurants/personal_restaurants_page.dart';
import 'package:rice/src/view/my_list_item.dart';
import 'package:rice/src/view/restaurant.dart';
import 'dart:developer' as developer;

import '../screen_arguments.dart';
import '../utils.dart';

import 'package:intl/intl.dart';

final dateFormat = new DateFormat('y/MM/dd');

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required ProfileBloc profileBloc,
  })  : _profileBloc = profileBloc,
        super(key: key);

  final ProfileBloc _profileBloc;

  @override
  ProfileScreenState createState() {
    return ProfileScreenState(_profileBloc);
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  final ProfileBloc _profileBloc;
  ProfileScreenState(this._profileBloc);

  ExpandableController? _expandableController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadCurrentProfile();
    });
  }

  void _loadCurrentProfile() {
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is ProfilePageArguments) {
      _load(
        userId: args.userId,
      );
    } else {
      _load(userId: null);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() {
    // if (!_pc.isPanelClosed()) {
    //   _pc.close();
    //   return Future.value(false);
    // }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_expandableController == null) {
      _expandableController =
          // ExpandableController.of(context, rebuildOnChange: false);
          ExpandableController();
      _expandableController!.toggle();
      _expandableController!.addListener(() {
        setState(() {
          isExpanded = !isExpanded;
        });
      });
    }
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: widget._profileBloc,
        builder: (
          BuildContext context,
          ProfileState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(
          context,
          currentState,
          builder: (
            BuildContext context,
            ProfileState currentState,
          ) {
            List<Widget> list = [
              _buildBody(context, currentState),
            ];

            if (currentState is ErrorProfileState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ackAlert(context, currentState.errorMessage);
              });
            }

            return WillPopScope(
              onWillPop: _onWillPop,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: list,
              ),
            );
          },
        ),
      ),
    );
  }

  _buildHeadBar(BuildContext context, ProfileState currentState) {
    final List<Widget> widgets = [];

    if (currentState is InProfileState &&
        currentState.currentUser.id != currentState.profile.userId) {
      widgets.add(
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    } else {
      widgets.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, NotificationPage.routeName);
              },
              child: Icon(Ionicons.notifications_outline),
            )
          ],
        ),
      );

      widgets.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _navigateSettings();
              },
              child: Icon(Ionicons.reorder_three_outline, size: 28),
            )
          ],
        ),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }

  _buildProfileInfo(Profile profile, User currentUser) {
    final List<Widget> widgets = [];

    final isOtherUserProfile =
        profile?.userId != null ? currentUser?.id != profile?.userId : false;

    final List<String>? mutualWantToGo =
        currentUser.profile!.wantToGo != null && profile.wantToGo != null
            ? currentUser.profile!.wantToGo!
                .toSet()
                .where((element) => profile.wantToGo!.toSet().contains(element))
                .toList()
            : null;

    final List<String>? mutualBeenTo =
        currentUser.profile!.beenTo != null && profile.beenTo != null
            ? currentUser.profile!.beenTo!
                .toSet()
                .where((element) => profile.beenTo!.toSet().contains(element))
                .toList()
            : null;

    print('Mutual eh: $mutualWantToGo');

    if (isOtherUserProfile) {
      widgets.add(
        GestureDetector(
          onTap: () => _sendMessage(profile),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Color(0xFF3345A9),
                  ),
                ),
                child: Icon(
                  Ionicons.chatbox_ellipses_outline,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Message',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }

    widgets.add(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: profile != null && profile.picture != null
            ? CircleAvatar(
                radius: isOtherUserProfile ? 59 : 48,
                backgroundImage: CachedNetworkImageProvider(
                  profile.picture!.url!,
                ),
              )
            : SvgPicture.asset(
                'assets/images/default-profile-pic.svg',
              ),
      ),
    );

    if (isOtherUserProfile) {
      widgets.add(_buildFollowing(profile));
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: new BorderRadius.only(
            bottomLeft: const Radius.circular(14.0),
            bottomRight: const Radius.circular(14.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4.0, // has the effect of softening the shadow
            spreadRadius: 4.0, // has the effect of extending the shadow
            offset: Offset(
              0.0, // horizontal, move right 10
              2.0, // vertical, move down 10
            ),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          // height: 50,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              margin: isOtherUserProfile ? EdgeInsets.only(top: 16) : null,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                profile.name ?? '',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                profile?.location == null
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Ionicons.earth_outline, size: 18),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              profile?.location ?? '',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                      ),
                isOtherUserProfile &&
                        profile != null &&
                        profile.isFollowingUser!
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.people_outline,
                              color: Color(0xFFCCCCCCC),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Follows you',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                                color: Color(0xFFAAAAAA),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ExpandablePanel(
                controller: _expandableController,
                theme: ExpandableThemeData(
                  tapHeaderToExpand: true,
                  hasIcon: false,
                  alignment: Alignment.bottomRight,
                  animationDuration: Duration(milliseconds: 200),
                ),
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(4, 16, 0, 16),
                      child: Text(
                        isExpanded ? 'Show less' : 'Show more',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).buttonColor),
                  ],
                ),
                expanded: Container(),
                collapsed: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child:
                                Icon(Ionicons.person_circle_outline, size: 18),
                          ),
                          Expanded(
                            child: Text(
                              profile?.bio ?? 'Unknown',
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Ionicons.chatbox_ellipses_outline,
                                size: 18),
                          ),
                          Expanded(
                            child: Text(
                              (profile?.languages?.isNotEmpty ?? false)
                                  ? profile.languages!.join(',')
                                  : 'Unknown',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Ionicons.heart_outline, size: 18),
                          ),
                          Expanded(
                            child: Text(
                              profile?.favoriteFood ?? 'Unknown',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child:
                                Icon(Ionicons.heart_dislike_outline, size: 18),
                          ),
                          Expanded(
                            child: Text(
                              profile?.cantEatFood ?? 'Unknown',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          FollowListPage.routeName,
                          arguments: FollowListPageArguments(
                              type: FollowListPageArgumentType.Following,
                              userIds: profile.following),
                        );
                        _load(userId: null);
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(),
                            child: Text('Following',
                                softWrap: false,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '${profile?.following?.length ?? 0}',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.button,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.of(context).pushNamed(
                            FollowListPage.routeName,
                            arguments: FollowListPageArguments(
                                type: FollowListPageArgumentType.Followers,
                                userIds: profile.followers),
                          );
                          _load(userId: null);
                        },
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(),
                              child: Text(
                                'Followers',
                                softWrap: false,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('${profile?.followers?.length ?? 0}',
                                  softWrap: false,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.button),
                            )
                          ],
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child: InkWell(
                      onTap: profile.beenTo != null
                          ? () {
                              Navigator.of(context).pushNamed(
                                PersonalRestaurantsPage.routeName,
                                arguments: PersonalRestaurantsPageArguments(
                                    listId: null,
                                    name: 'Been To',
                                    restaurants: profile.beenTo,
                                    mutualRestaurants: isOtherUserProfile
                                        ? mutualBeenTo
                                        : null,
                                    by: profile.name,
                                    readonly: true,
                                    sharedRestaurantsView: isOtherUserProfile),
                              );
                            }
                          : () {},
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(),
                            child: Text(
                              'Been to',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '${profile.beenTo?.length ?? 0}',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.button,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child: InkWell(
                      onTap: profile.wantToGo != null
                          ? () {
                              Navigator.of(context).pushNamed(
                                PersonalRestaurantsPage.routeName,
                                arguments: PersonalRestaurantsPageArguments(
                                    listId: null,
                                    name: 'Want To Go',
                                    restaurants: profile.wantToGo,
                                    mutualRestaurants: isOtherUserProfile
                                        ? mutualWantToGo
                                        : null,
                                    by: profile.name,
                                    readonly: true,
                                    sharedRestaurantsView: isOtherUserProfile),
                              );
                            }
                          : () {},
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(),
                            child: Text(
                              'Want to go',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '${profile.wantToGo?.length ?? 0}',
                              softWrap: false,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.button,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildFollowing(Profile profile) {
    return GestureDetector(
      onTap: () => _toggleFriendship(profile),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: profile?.isFollowedByUser == true
                  ? Color(0xFF3345A9)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Color(0xFF3345A9),
              ),
            ),
            child: Icon(
              profile?.isFollowedByUser == true
                  ? Ionicons.person_remove_outline
                  : Ionicons.person_add_outline,
              color: profile?.isFollowedByUser == true
                  ? Colors.white
                  : Color(0xFF3345A9),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            profile?.isFollowedByUser == true ? 'Following' : 'Follow',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  _sendMessage(Profile profile) async {
    final chat = await this.widget._profileBloc.startChat(
          User(
            id: profile.userId,
            emails: [],
            username: '',
            profile: profile,
          ),
        );

    await Navigator.of(context).pushNamed(
      ChatRoomPage.routeName,
      arguments: ChatRoomPageArguments(
        0,
        metadata: chat,
      ),
    );

    _loadCurrentProfile();
  }

  _toggleFriendship(Profile profile) {
    widget._profileBloc.add(
      ToggleFriendshipEvent(userId: profile.userId),
    );
  }

  _buildBody(BuildContext context, ProfileState currentState) {
    Profile? profile = null;
    User? currentUser = null;

    if (currentState is InProfileState) {
      profile = currentState.profile;
      currentUser = currentState.currentUser;
    }

    if (profile == null) {
      return Scaffold();
    }

    final photoIndexes = (profile.photos != null && profile.photos!.isNotEmpty)
        ? List.generate(profile.photos!.length, (index) => index)
        : [];

    developer.log('Profile: ${profile.toJson()}');

    final isOtherUserProfile = (currentUser == null || profile == null)
        ? false
        : currentUser.id != profile.userId;

    return CustomScrollView(
        // controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: <Widget>[
                    Stack(children: [
                      _buildProfileInfo(profile, currentUser!),
                      SafeArea(child: _buildHeadBar(context, currentState)),
                    ]),
                    _exploreSection(
                      'Upcoming plans',
                      '',
                      200,
                      profile.upcomingPlans
                              ?.map((e) => _buildPlanItem(e))
                              ?.toList() ??
                          [],
                      () async {
                        await Navigator.of(context).pushNamed(
                          ExplorePlansPage.routeName,
                          arguments: ExplorePlansPageArguments(
                            title: 'Upcoming Plans',
                          ),
                        );

                        _loadCurrentProfile();
                      },
                      emptyMessage: isOtherUserProfile
                          ? 'This person has no upcoming plans'
                          : 'You currently have no upcoming plans',
                      emptyAction: isOtherUserProfile ? null : 'Create a plan',
                      emptyNamedRoute:
                          isOtherUserProfile ? null : CreatePlanPage.routeName,
                    ),
                    _exploreSection(
                      'Photos',
                      '',
                      148,
                      photoIndexes
                          .map(
                            (index) => _buildPhotoItem(
                              index,
                              profile!.photos![index],
                              profile.photos,
                            ),
                          )
                          .toList(),
                      () async {
                        await Navigator.of(context).pushNamed(
                          PhotoListPage.routeName,
                          arguments: PhotoListPageArguments(
                            profile!.photos,
                          ),
                        );

                        _loadCurrentProfile();
                      },
                      emptyMessage: isOtherUserProfile
                          ? 'This person has no photos'
                          : 'Photos from your reviews will be shown here when you add them',
                    ),
                    _exploreSection(
                      'Favorites',
                      '',
                      216,
                      profile == null || profile.favorites == null
                          ? []
                          : profile.favorites!.map(_buildFavoriteItem).toList(),
                      () async {
                        await Navigator.of(context).pushNamed(
                          PersonalRestaurantsPage.routeName,
                          arguments: PersonalRestaurantsPageArguments(
                            name: 'Favorites',
                            listId: profile!.favoriteListId,
                            readonly: isOtherUserProfile,
                          ),
                        );

                        _loadCurrentProfile();
                      },
                      emptyMessage: isOtherUserProfile
                          ? 'This person has no favorite restaurants'
                          : 'Your favorites will be shown here when you add them',
                    ),
                    _exploreSection(
                        'Lists',
                        '',
                        224,
                        profile == null || profile.lists == null
                            ? []
                            : profile.lists!
                                .map(
                                  (personalListItem) => _buildMyListItem(
                                    personalListItem,
                                    isOtherUserProfile,
                                  ),
                                )
                                .toList(),
                        () async {
                          await Navigator.of(context).pushNamed(
                            PersonalListsPage.routeName,
                            arguments: PersonalListsPageArguments(
                              userId: profile!.userId,
                            ),
                          );

                          _loadCurrentProfile();
                        },
                        emptyMessage: isOtherUserProfile
                            ? 'This person has no lists'
                            : 'You currently have no lists',
                        emptyAction:
                            isOtherUserProfile ? null : 'Create a List',
                        onActionPressed: () async {
                          await Navigator.of(context).pushNamed(
                            PersonalListsPage.routeName,
                            arguments: PersonalListsPageArguments(
                              userId: profile!.userId,
                            ),
                          );

                          _loadCurrentProfile();
                        }),
                  ],
                ),
              )
            ]),
          )
        ]);
  }

  Widget _buildPlanItem(Plan plan) {
    final avatarWrapper = (int index, Widget child) => Positioned(
          left: index * 24.0,
          child: child,
        );

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          PlanDetailPage.routeName,
          arguments: plan,
        );

        _loadCurrentProfile();
      },
      child: Container(
        width: 335,
        height: 140,
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(2, 1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      plan.restaurant!.name!,
                      style: Theme.of(context).textTheme.subtitle2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(intl.DateFormat.yMMMEd().format(plan.planDate!),
                      // dateFormat.format(plan.planDate),
                      style: Theme.of(context).textTheme.headline4)
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: buildImage(
                    width: 72,
                    height: 72,
                    url: plan.restaurant!.photo,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        plan.restaurant!.address!,
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                      ),
                      SizedBox(height: 2),
                      Text('Hosted By: You',
                          style: Theme.of(context).textTheme.headline4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 7),
                            width: 112,
                            height: 32,
                            child: Stack(
                              children: buildAvatarRow(
                                  photos: plan.users!
                                      .map(
                                        (user) => user.profile!.picture!.url,
                                      )
                                      .toList(),
                                  limit: 3,
                                  buildWrapper: avatarWrapper,
                                  context: context),
                            ),
                          ),
                          Icon(
                            plan.isPublic!
                                ? Ionicons.lock_open_outline
                                : Ionicons.lock_closed_outline,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index, String photo, List<String>? photos) {
    return GestureDetector(
      onTap: () {
        open(
          context,
          index,
          photos!
              .map(
                (e) => GalleryItem(id: '$index', resource: e),
              )
              .toList(),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: photo == null
              ? null
              : DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(photo),
                ),
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(Restaurant favorite) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          RestaurantDetailPage.routeName,
          arguments: RestaursntDetailPageArguments(favorite),
        );

        _loadCurrentProfile();
      },
      child: Container(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildImage(
              width: 160,
              height: 100,
              url: favorite.photo,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              favorite.name!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              favorite.address!,
              style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMyListItem(ListMetadata list, bool isOtherUserProfile) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          PersonalRestaurantsPage.routeName,
          arguments: PersonalRestaurantsPageArguments(
            listId: list.id,
            name: list.name,
            readonly: isOtherUserProfile,
          ),
        );

        _loadCurrentProfile();
      },
      child: MyListItem(metadata: list),
    );
  }

  Widget _exploreSection(
    String title,
    String namedRoute,
    double height,
    List<Widget> children,
    void onSeeAllClicked(), {
    required String emptyMessage,
    String? emptyAction,
    String? emptyNamedRoute,
    VoidCallback? onActionPressed,
  }) {
    final titleWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(title, style: Theme.of(context).textTheme.subtitle1),
    );

    if (children.isEmpty) {
      return SizedBox(
        height: 148,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 14.0, horizontal: 6),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        color: Color.fromARGB(255, 170, 170, 170),
                      ),
                    ),
                    emptyAction == null
                        ? Container()
                        : TextButton(
                            child: Text(
                              emptyAction,
                              style: TextStyle(
                                color: Color.fromARGB(255, 51, 69, 169),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () async {
                              if (emptyNamedRoute != null) {
                                await Navigator.of(context).pushNamed(
                                  emptyNamedRoute,
                                );

                                _loadCurrentProfile();
                              } else if (onActionPressed != null) {
                                onActionPressed();
                              }
                            },
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                titleWidget,
                GestureDetector(
                  onTap: onSeeAllClicked,
                  child: Text('See all >',
                      style: Theme.of(context).textTheme.button),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    children[index],
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 16);
              },
              itemCount: children.length > 6 ? 6 : children.length,
            ),
          ),
        ],
      ),
    );
  }

  void _load({
    required String? userId,
    bool isError = false,
  }) {
    widget._profileBloc.add(UnProfileEvent());

    widget._profileBloc.add(LoadProfileEvent(
      isError,
      userId: userId,
    ));
  }

  _navigateSettings() async {
    await Navigator.pushNamed(context, SettingsPage.routeName);
    _loadCurrentProfile();
  }

  navigateOnBoarding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        OnboardingPage.routeName,
      );
    });
  }
}
