import 'package:collection/collection.dart' show IterableNullableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../base_bloc.dart';
import '../create_plan/create_plan_page.dart';
import '../find_chat_partner/find_chat_partner_page.dart';
import '../personal_lists/personal_lists_page.dart';
import '../photo_list/index.dart';
import '../repository/google_place_service.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import 'index.dart';
import '../restaurant_review/index.dart';
import '../review_list/index.dart';
import '../screen_arguments.dart';
import '../view/awards.dart';
import '../view/restaurant.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:developer' as developer;

import '../utils.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    Key? key,
    required RestaurantDetailBloc restaurantDetailBloc,
  })  : _restaurantDetailBloc = restaurantDetailBloc,
        super(key: key);

  final RestaurantDetailBloc _restaurantDetailBloc;

  @override
  RestaurantDetailScreenState createState() {
    return RestaurantDetailScreenState(_restaurantDetailBloc);
  }
}

class RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final RestaurantDetailBloc _restaurantDetailBloc;
  RestaurantDetailScreenState(this._restaurantDetailBloc);

  PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();

    this._load();
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
    final RestaursntDetailPageArguments? args = ModalRoute.of(context)!
        .settings
        .arguments as RestaursntDetailPageArguments?;

    return BlocBuilder<RestaurantDetailBloc, RestaurantDetailState>(
        bloc: widget._restaurantDetailBloc,
        builder: (
          BuildContext context,
          RestaurantDetailState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              RestaurantDetailState currentState,
            ) {
              if (currentState is ErrorRestaurantDetailState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    widget._restaurantDetailBloc.add(UnRestaurantDetailEvent());
                  });
                });
              }
              return WillPopScope(
                  onWillPop: _onWillPop,
                  child: _buildSlidingUpPanel(
                      CustomScrollView(slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeadBar(args!.restaurant!),
                        ),
                        SliverToBoxAdapter(
                          child: Stack(
                            children: <Widget>[
                              _buildBody(
                                  context, args.restaurant!, currentState),
                            ],
                          ),
                        )
                      ]),
                      args.restaurant,
                      currentState));
            }));
  }

  void _load([bool isError = false]) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RestaursntDetailPageArguments args = ModalRoute.of(context)!
          .settings
          .arguments as RestaursntDetailPageArguments;

      widget._restaurantDetailBloc.add(UnRestaurantDetailEvent());
      widget._restaurantDetailBloc.add(
        LoadRestaurantDetailEvent(
          args.restaurant,
        ),
      );
    });
  }

  _buildHeadBar(Restaurant restaurant) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: restaurant.photo == null
              ? null
              : DecorationImage(
                  colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.dstATop,
                  ),
                  fit: BoxFit.cover,
                  image: NetworkImage(restaurant.photo!),
                ),
        ),
        child: _headerContent(restaurant));
  }

  Widget _headerContent(Restaurant restaurant) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                Ionicons.close_outline,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Ionicons.share_outline,
                color: Colors.white,
              ),
              onPressed: () => _shareRestaurant(restaurant),
            ),
            IconButton(
                icon: Icon(
                  Ionicons.bookmark_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showSlidingUpPanel();
                }),
          ],
        ),
        Container(
          width: 250,
          padding: EdgeInsets.only(left: 16, bottom: 16),
          child: Text(restaurant.name!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    child: Text(
                  restaurant.address!,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                )),
              ),
              SizedBox(
                width: 16,
              ),
              restaurant.rating == null
                  ? Container()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Color(0xFFF7C669),
                          size: 24,
                        ),
                        SizedBox(width: 5),
                        Text(restaurant.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ))
                      ],
                    ),
            ],
          ),
        ),
        Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Container(
                  height: 21,
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor)),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ButtonTheme(
                  minWidth: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      shape: StadiumBorder(),
                    ),
                    child: Text("Create new plan",
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        CreatePlanPage.routeName,
                        arguments: CreatePlanPageArguments(
                          restaurant,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  _shareRestaurant(Restaurant restaurant) {
    developer.log('Share Restaurant $restaurant');

    Navigator.of(context).pushNamed(
      FindChatPartnerPage.routeName,
      arguments: FindChatPartnerPageArguments(
        restaurant: restaurant,
      ),
    );
  }

  _buildLocation(Restaurant restaurant) {
    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () => launchMapsByLocationUrl(
                    restaurant.location!.coordinates![1],
                    restaurant.location!.coordinates![0]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  child: Text(
                                    'Location',
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ))),
                        ],
                      ),
                    ),
                    Container(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3, vertical: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: ClipRRect(
                                      borderRadius:
                                          new BorderRadius.circular(8.0),
                                      child: Image.network(
                                        restaurant?.location?.coordinates !=
                                                null
                                            ? "https://maps.googleapis.com/maps/api/staticmap?center=${restaurant?.location?.coordinates![1]},${restaurant?.location?.coordinates![0]}&zoom=18&size=256x256&key=${GooglePlaceService.API_KEY}"
                                            : SizedBox() as String,
                                        fit: BoxFit.fill,
                                        width: 96,
                                        height: 96,
                                      )),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(6, 4, 56, 4),
                                      child: Text(
                                        restaurant.address!,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          color: Color(0xFF222222),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      )),
                                ),
                              ],
                            ))),
                  ],
                ))));
  }

  _buildContact(Restaurant restaurant) {
    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Text(
                                'Contact',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.subtitle1,
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () => launchTel(restaurant.phone),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  child: Text(
                                    restaurant.phone != null
                                        ? restaurant.phone!
                                        : "",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color:
                                            Color.fromARGB(255, 51, 69, 169)),
                                  )))),
                    ],
                  ),
                ),
              ],
            )));
  }

  _buildDayOpenHours(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  '${day.split(":").first}:',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ))),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  '${day.substring(day.split(":").first.length + 1)}',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ))),
      ],
    );
  }

  _buildOpenHours(Restaurant restaurant) {
    String openingHours = '';

    if (restaurant.openingHoursDetail == null) {
      openingHours = 'Opening Hours Not Specified';
    } else if (restaurant.openingHoursDetail!.openNow!) {
      openingHours = 'Open';
    } else {
      openingHours = 'Closed';
    }

    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Text(
                                  'Opening hours',
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ))),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Text(
                              openingHours,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Color(0xFF8DCA3E)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: restaurant?.openingHoursDetail != null
                          ? Column(
                              children: <Widget>[
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![0]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![1]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![2]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![3]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![4]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![5]}'),
                                _buildDayOpenHours(
                                    '${restaurant.openingHoursDetail!.weekdayText![6]}'),
                              ],
                            )
                          : SizedBox())
                ])));
  }

  _buildContent(Restaurant restaurant, List<String> photos,
      List<Review> reviews, bool hasReviewed) {
    return Column(
      children: List<Widget>.from([
        RestaurantVisitedFriendsRow(restaurant),
        restaurant.awardDetail != null ? Awards() : null,
        RestaurantGalleryRow(
          restaurant,
          photos == null ? [] : photos,
          tappedCallback: () => _navigatePhotoList(photos),
        ),
        RestaurantReviewsRow(
          restaurant,
          reviews,
          tappedAllCallback: () => _navigateReviewList(reviews),
          tappedAddReviewCallback: () => _navigateAddReview(restaurant),
          enableAddingReview: !hasReviewed,
        ),
        _buildLocation(restaurant),
        _buildContact(restaurant),
        _buildOpenHours(restaurant),
      ].whereNotNull()),
    );
  }

  _buildBody(BuildContext context, Restaurant restaurant,
      RestaurantDetailState currentState) {
    return Container(
      child: Column(
        children: [
          _buildContent(
              restaurant,
              (currentState is InRestaurantDetailState)
                  ? currentState.photos
                  : [],
              (currentState is InRestaurantDetailState)
                  ? currentState.reviews
                  : [],
              (currentState is InRestaurantDetailState)
                  ? currentState.hasReviewed
                  : false),
        ],
      ),
    );
  }

  _buildSlidingUpPanel(
      Widget body, Restaurant? restaurant, RestaurantDetailState currentState) {
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: 0,
      maxHeight: 120,
      margin: EdgeInsets.all(8),
      backdropEnabled: true,
      slideDirection: SlideDirection.UP,
      panel: Center(
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildSlidingUpPanelButton(
                          iconOn: Icon(Ionicons.happy_outline,
                              color: Color(0xFFF7C669), size: 40),
                          iconOff: Icon(Ionicons.happy_outline,
                              color: Color(0xFFD8D8D8), size: 40),
                          // iconOn: "assets/icon/ic_map_marker_alt.svg",
                          // iconOff: "assets/icon/ic_map_marker_alt.svg",
                          isOn: currentState is InRestaurantDetailState
                              ? currentState.isAddToWantToGoList!
                              : false,
                          text: "Want to go",
                          onClick: () => widget._restaurantDetailBloc
                              .add(OnAddToWantToGoListEvent(restaurant))),
                      _buildSlidingUpPanelButton(
                          iconOn: Icon(Ionicons.checkmark_outline,
                              color: Color(0xFFF7C669), size: 40),
                          iconOff: Icon(Ionicons.checkmark_outline,
                              color: Color(0xFFD8D8D8), size: 40),
                          // iconOn: "assets/icon/ic_map_marker_alt_1.svg",
                          // iconOff: "assets/icon/ic_map_marker_alt_1.svg",
                          isOn: currentState is InRestaurantDetailState
                              ? currentState.isAddToBeenList!
                              : false,
                          text: "Been",
                          onClick: () => widget._restaurantDetailBloc
                              .add(OnAddToBeenListEvent(restaurant))),
                      _buildSlidingUpPanelButton(
                        iconOn: Icon(Ionicons.document_text_outline,
                            color: Color(0xFFF7C669), size: 40),
                        iconOff: Icon(Ionicons.document_text_outline,
                            color: Color(0xFFD8D8D8), size: 40),

                        // iconOn: "assets/icon/ic_list_alt.svg",
                        // iconOff: "assets/icon/ic_list_alt.svg",
                        isOn: currentState is InRestaurantDetailState
                            ? currentState.isAddToMyLists
                            : false,
                        text: "Add to list",
                        onClick: () {
                          if (currentState is InRestaurantDetailState) {
                            Navigator.of(context).pushNamed(
                              PersonalListsPage.routeName,
                              arguments: PersonalListsPageArguments(
                                userId: currentState.currentUser.id,
                                restaurant: restaurant,
                              ),
                            );
                          }
                        },
                      ),
                      _buildSlidingUpPanelButton(
                        iconOn: Icon(Ionicons.star_outline,
                            color: Color(0xFFF7C669), size: 40),
                        iconOff: Icon(Ionicons.star_outline,
                            color: Color(0xFFD8D8D8), size: 40),
                        // iconOn: "assets/icon/ic_star.svg",
                        // iconOff: "assets/icon/ic_star.svg",
                        isOn: currentState is InRestaurantDetailState
                            ? currentState.isAddToFavoritesList
                            : false,
                        text: "Favorite",
                        onClick: () => widget._restaurantDetailBloc.add(
                          OnAddToFavoriteListEvent(restaurant),
                        ),
                      )
                    ]),
              ],
            ),
          ),
        ),
      ),
      backdropColor: Colors.black,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      body: body,
    );
  }

  _buildSlidingUpPanelButton(
      {Icon? iconOn,
      Icon? iconOff,
      required String text,
      bool isOn = false,
      void Function()? onClick}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onClick!(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            isOn ? iconOn! : iconOff!,

            // SvgPicture.asset(
            //   isOn ? iconOn : iconOff,
            //   width: 40,
            //   height: 40,
            //   color: isOn ? Color(0xFFF7C669) : Color(0xFFD8D8D8),
            // ),
            //Icon(isOn ? iconOn : iconOff, size: 40, color: isOn ? Color(0xFF3345A9) : Color(0xFFD8D8D8)),
            SizedBox(
              height: 16,
            ),
            Text(text, maxLines: 1, style: Theme.of(context).textTheme.button)
          ],
        ),
      ),
    );
  }

  //region Navigation
  _navigatePhotoList(List<String> photoUrls) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamed(context, PhotoListPage.routeName,
        arguments: PhotoListPageArguments(photoUrls));
    // });
  }

  _navigateReviewList(List<Review> reviews) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamed(context, ReviewListPage.routeName,
        arguments: ReviewListPageArguments(reviews));
    // });
  }

  _navigateAddReview(Restaurant restaurant) async {
    final result = await Navigator.pushNamed(
      context,
      RestaurantReviewPage.routeName,
      arguments: RestaurantReviewPageArguments(restaurant),
    );

    if (result != null && result as bool) {
      _load();
    }
  }

  Future<String> _navigateToMyListsForListId() async {
    return "listId";
//    return await Navigator.pushNamed(
//        context, Resta.routeName,
//        arguments: RestaurantReviewPageArguments(restaurant));
  }
  //endregion

  _showSlidingUpPanel() {
    _panelController.open();
  }
}
