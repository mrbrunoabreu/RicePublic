import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../base_bloc.dart';
import 'package:rice/src/explore/cluster_controller.dart';
import 'package:rice/src/profile/index.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import 'package:rice/src/restaurant_detail/restaurant_detail_page.dart';
import 'package:rice/src/search_result/index.dart';
import 'package:rice/src/view/map_marker.dart';
import 'package:rice/src/view/restaurant.dart';
import 'package:rice/src/view/screen_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tuple/tuple.dart';
import 'package:ionicons/ionicons.dart';

import '../screen_arguments.dart';
import '../utils.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({
    Key? key,
    required SearchResultScreenState state,
    required SearchResultBloc searchResultBloc,
    required String searchTerm,
  })  : _searchResultBloc = searchResultBloc,
        _state = state,
        _searchTerm = searchTerm,
        super(key: key);

  final SearchResultBloc _searchResultBloc;
  final SearchResultScreenState _state;
  final String _searchTerm;

  @override
  SearchResultScreenState createState() {
    return _state;
  }
}

abstract class SearchResultScreenState extends State<SearchResultScreen> {
  final SearchResultBloc _searchResultBloc;

  SearchResultViewType viewType;
  SearchResultScreenState(this._searchResultBloc, this.viewType);

  @override
  void initState() {
    super.initState();
    this.load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void load();

  // void _load([bool isError = false]) {
  //   widget._searchResultBloc.add(UnSearchResultEvent());
  //   widget._searchResultBloc.add(LoadSearchResultEvent(isError));
  // }
}

class KeywordSearchResultScreenState extends SearchResultScreenState
    with SingleTickerProviderStateMixin {
  final String keyword;

  TabController? _tabController;

  KeywordSearchResultScreenState(this.keyword,
      SearchResultBloc searchResultBloc, SearchResultViewType viewType)
      : super(searchResultBloc, viewType);

  @override
  void initState() {
    this._tabController =
        TabController(initialIndex: 1, length: 3, vsync: this);
    super.initState();
  }

  @override
  void load() {
    widget._searchResultBloc.add(UnSearchResultEvent());
    widget._searchResultBloc.add(LoadKeywordSearchResultEvent(this.keyword));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultBloc, SearchResultState>(
        bloc: widget._searchResultBloc,
        builder: (
          BuildContext context,
          SearchResultState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              SearchResultState currentState,
            ) {
              if (currentState is ErrorSearchResultState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }

              List<Tuple2<Restaurant, List<String>>> restaurants = currentState
                          .props !=
                      null
                  ? currentState.props
                      .firstWhere(
                          (test) => test.item1 == SearchResultState.restaurants,
                          orElse: () => Tuple2(SearchResultState.restaurants,
                              const <Tuple2<Restaurant, List<String>>>[]))
                      .item2 as List<Tuple2<Restaurant, List<String>>>
                  : [];

              if (this.viewType == SearchResultViewType.Normal) {
                return _buildNormalViewType(context, restaurants);
              } else {
                return _buildMapViewType(context, restaurants);
              }
            }));
  }

  _buildNormalViewType(BuildContext context,
      List<Tuple2<Restaurant, List<String>>> restaurants) {
    return Scaffold(
      //appBar: _appBar("'Results for ${args.arguments.name}")
      appBar:
          _appBar("Results for ${widget._searchTerm}") as PreferredSizeWidget?,
      body: SafeArea(
          child: Container(
        child: TabBarView(
          children: restaurants.isNotEmpty
              ? [
                  _buildAllRestaurantsTabView(restaurants),
                  _buildRatedRestaurantsTabView(restaurants),
                  _buildListRestaurantsTabView(restaurants)
                ]
              : [SizedBox(), SizedBox(), SizedBox()],
          controller: this._tabController,
        ),
      )),
      //floatingActionButton: _floatingActionButton()
    );
  }

  double _currentZoom = 14.4746;
  ClusterController? _clusterController;
  final _autoScrollController = AutoScrollController(
      //add this for advanced viewport boundary. e.g. SafeArea
      // viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),

      //choose vertical/horizontal
      axis: Axis.horizontal,

      //this given value will bring the scroll offset to the nearest position in fixed row height case.
      //for variable row height case, you can still set the average height, it will try to get to the relatively closer offset
      //and then start searching.
      suggestedRowHeight: 200);

  Completer<GoogleMapController> _controller = Completer();

  MapMarker _toMarker(Restaurant restaurant, int index) {
    // return Marker(
    //   markerId: MarkerId(restaurant.googlePlaceId),
    //   position: LatLng(restaurant.location.coordinates[1],
    //       restaurant.location.coordinates[0]),
    //   icon: BitmapDescriptor.defaultMarker,
    // );

    return MapMarker(
        locationName: restaurant.name,
        latitude: restaurant.location!.coordinates![1],
        longitude: restaurant.location!.coordinates![0],
        markerId: MarkerId(restaurant.googlePlaceId!),
        onTap: () {
          _autoScrollController.scrollToIndex(index,
              preferPosition: AutoScrollPosition.begin);
        });
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _currentZoom = cameraPosition.zoom;
  }

  void _onCameraIdle() {
    if (_clusterController != null) {
      _clusterController!.setCameraZoom(_currentZoom);
    }
  }

  _buildMapViewType(BuildContext context,
      List<Tuple2<Restaurant, List<String>>> restaurants) {
    final SearchResultPageArguments args =
        ModalRoute.of(context)!.settings.arguments as SearchResultPageArguments;

    Map<String?, MapMarker> toMap() {
      Map<String?, MapMarker> map = LinkedHashMap<String?, MapMarker>();
      int index = 0;

      restaurants.forEach((r) {
        map.putIfAbsent(r.item1.googlePlaceId, () => _toMarker(r.item1, index));
        index++;
      });
      return map;
    }

    // final Set<Marker> restaurantsSet = restaurants.map((r) => _toMarker(r)).toSet();
    _clusterController = ClusterController(toMap());
    _controller.future.then((gmCtrller) {
      var list = restaurants
          .map((r) => LatLng(r.item1.location!.coordinates![1],
              r.item1.location!.coordinates![0]))
          .toList();
      calculateCentral(list).then((central) {
        return gmCtrller.moveCamera(CameraUpdate.newLatLng(
            LatLng(central.latitude, central.longitude)));
      });
    });

    CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(args.arguments.lat, args.arguments.lng),
      zoom: 14.4746,
    );

    return Stack(children: <Widget>[
      StreamBuilder<Map<MarkerId, Marker>>(
          stream: _clusterController!.markers,
          builder: (context, snapshot) {
            return GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              markers: (snapshot.data != null)
                  ? Set.of(snapshot.data!.values)
                  : Set(),
            );
          }),
      Align(
          alignment: Alignment(0.9, 0.37),
          child: FloatingActionButton(
              onPressed: () {
                SearchResultPage.toggleNavigate(context, args);
              },
              child: Icon(Icons.format_list_bulleted),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))))),
      Align(
          alignment: Alignment(0.0, 0.99),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24),
            child: SizedBox(
                height: 200,
                child: ListView.builder(
                  controller: _autoScrollController,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurants.length, // included head sized box
                  itemBuilder: (context, index) {
                    Card card = Card(
                      elevation: 5.0,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(14.0))),
                      child: SizedBox(
                        height: 100,
                        width: 380,
                        child: RestaurantRow(
                          restaurants[index].item1,
                          photos: restaurants[index].item2,
                          onTapCallback: () => _navigateToRestaurantDetails(
                            restaurants[index].item1,
                          ),
                        ),
                      ),
                    );
                    return AutoScrollTag(
                        key: ValueKey(index),
                        controller: _autoScrollController,
                        index: index,
                        child: card);
                  },
                )),
          )),
    ]);
  }

  _buildRestaurants(int size, Widget itemBuilder(context, index)) {
    return ListView.separated(
        itemCount: size,
        separatorBuilder: (context, index) => SizedBox(),
        itemBuilder: (context, index) {
          return itemBuilder(context, index);
        });
  }

  _buildRatedRestaurantsTabView(
      List<Tuple2<Restaurant, List<String>>> restaurants) {
    var headItem = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('${restaurants.length} results',
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.subtitle2),
                DropdownButton<String>(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Theme.of(context).buttonColor),
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'Highest rated',
                      child: Text(
                        'Highest rated',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Lowest rated',
                      child: Text('Lowest rated',
                          style: Theme.of(context).textTheme.button),
                    ),
                  ],
                  onChanged: (value) {},
                  value: 'Highest rated',
                ),
              ],
            )),
        RestaurantRow(
          restaurants[0].item1,
          photos: restaurants[0].item2,
          onTapCallback: () => _navigateToRestaurantDetails(
            restaurants[0].item1,
          ),
        )
      ],
    );

    return _buildRestaurants(restaurants.length, (context, index) {
      if (index == 0) {
        return headItem;
      }

      return RestaurantRow(
        restaurants[index].item1,
        photos: restaurants[index].item2,
        onTapCallback: () => _navigateToRestaurantDetails(
          restaurants[index].item1,
        ),
      );
    });
  }

  _navigateToRestaurantDetails(Restaurant restaurant) {
    Navigator.of(context).pushNamed(
      RestaurantDetailPage.routeName,
      arguments: RestaursntDetailPageArguments(
        restaurant,
      ),
    );
  }

  _buildAllRestaurantsTabView(
      List<Tuple2<Restaurant, List<String>>> restaurants) {
    return _buildRestaurants(
      restaurants.length,
      (context, index) => RestaurantRow(
        restaurants[index].item1,
        photos: restaurants[index].item2,
        onTapCallback: () => _navigateToRestaurantDetails(
          restaurants[index].item1,
        ),
      ),
    );
  }

  _buildListRestaurantsTabView(
    List<Tuple2<Restaurant, List<String>>> restaurants,
  ) {
    return _buildRestaurants(
      restaurants.length,
      (context, index) => RestaurantRow(restaurants[index].item1,
          photos: restaurants[index].item2,
          onTapCallback: () => _navigateToRestaurantDetails(
                restaurants[index].item1,
              )),
    );
  }

  //region Widgets -------------------------------------------------------------
  Widget _appBar(String text) {
    Text title = Text(text, style: Theme.of(context).textTheme.subtitle2);

    Widget subTitle = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Ionicons.location_outline, size: 18),
        SizedBox(
          width: 8,
        ),
        Text("Places around me", style: Theme.of(context).textTheme.subtitle2)
      ],
    );

    Widget tabs = TabBar(
      tabs: [
        Tab(text: 'ALL'),
        Tab(text: 'RESTAURANTS'),
        Tab(text: 'LISTS'),
      ],
      unselectedLabelColor: Theme.of(context).disabledColor,
      labelColor: Theme.of(context).primaryColor,
      indicatorWeight: 3,
      indicatorColor: Theme.of(context).primaryColor,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      controller: this._tabController,
    );

    Widget horizontalLine = Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFF1F1F1),
          ),
        )
      ],
    );

    return ScreenBar(
      title,
      rightIcon: Icon(Ionicons.options_outline),
      bottom: PreferredSize(
        preferredSize: Size(0, 80),
        child: Center(
          child: Container(
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: subTitle),
                ),
                tabs,
                horizontalLine
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
        onPressed: () {
          //toggleNavigate(context, args);
        },
        child: SvgPicture.asset(
          'assets/icon/ic_map.svg',
          height: 72,
          width: 72,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))));
  }
  //endregion
}

class PlaceSearchResultScreenState extends SearchResultScreenState {
  final double currentLat;
  final double currentLng;

  PlaceSearchResultScreenState(SearchResultBloc searchResultBloc,
      SearchResultViewType viewType, this.currentLat, this.currentLng)
      : super(searchResultBloc, viewType);

  @override
  void load() {
    widget._searchResultBloc.add(UnSearchResultEvent());
    widget._searchResultBloc.add(LoadKeywordSearchResultEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultBloc, SearchResultState>(
        bloc: widget._searchResultBloc,
        builder: (
          BuildContext context,
          SearchResultState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              SearchResultState currentState,
            ) {
              if (currentState is ErrorSearchResultState) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(currentState.errorMessage ?? 'Error'),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text('reload'),
                        onPressed: () => this.load(),
                      ),
                    ),
                  ],
                ));
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Flutter files: done'),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('throw error'),
                        onPressed: () => this.load(),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}

class PeopleSearchResultScreenState extends SearchResultScreenState {
  final String keyword;

  PeopleSearchResultScreenState(this.keyword, SearchResultBloc searchResultBloc,
      SearchResultViewType viewType)
      : super(searchResultBloc, viewType);

  @override
  void initState() {
    super.initState();
  }

  @override
  void load() {
    widget._searchResultBloc.add(UnSearchResultEvent());
    widget._searchResultBloc.add(LoadPeopleSearchResultEvent(this.keyword));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultBloc, SearchResultState>(
        bloc: widget._searchResultBloc,
        builder: (
          BuildContext context,
          SearchResultState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              SearchResultState currentState,
            ) {
              if (currentState is ErrorSearchResultState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }

              List<User> people = currentState.props != null
                  ? currentState.props
                      .firstWhere(
                          (test) => test.item1 == SearchResultState.people,
                          orElse: () => Tuple2(SearchResultState.people, []))
                      .item2 as List<User>
                  : [];
              if (this.viewType == SearchResultViewType.Normal) {
                return _buildNormalViewType(
                  context,
                  people
                      .where((element) => element.profile?.name != null)
                      .toList(),
                );
              } else {
                throw ArgumentError(
                    "Not allowed the view type: " + this.viewType.toString());
              }
            }));
  }

  _buildNormalViewType(BuildContext context, List<User> people) {
    return Scaffold(
      //appBar: _appBar("'Results for ${args.arguments.name}")
      appBar:
          _appBar("Results for ${widget._searchTerm}") as PreferredSizeWidget?,
      body: SafeArea(
          child: Container(
        child: people.isNotEmpty
            ? _buildPeopleView(people)
            : SizedBox(
                child: Center(
                    child: Text('No result found',
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.subtitle1)),
              ),
      )),
      //floatingActionButton: _floatingActionButton()
    );
  }

  _buildPeople(int size, Widget itemBuilder(context, index)) {
    return ListView.separated(
        itemCount: size,
        separatorBuilder: (context, index) => SizedBox(),
        itemBuilder: (context, index) {
          return itemBuilder(context, index);
        });
  }

  _buildPeopleView(List<User> users) {
    var headItem = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('${users.length} results',
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.subtitle2),
              ],
            )),
        UserRow(
          users[0],
          onTapCallback: () => _navigateToUserProfile(
            users[0],
          ),
        )
      ],
    );

    return _buildPeople(users.length, (context, index) {
      if (index == 0) {
        return headItem;
      }

      return UserRow(
        users[index],
        onTapCallback: () => _navigateToUserProfile(
          users[index],
        ),
      );
    });
  }

  _navigateToUserProfile(User user) {
    Navigator.of(context).pushNamed(
      ProfilePage.routeName,
      arguments: ProfilePageArguments(
        userId: user.id,
      ),
    );
  }

  Widget _appBar(String text) {
    Text title = Text(text, style: Theme.of(context).textTheme.subtitle2);

    Widget subTitle = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Ionicons.people, size: 18),
        SizedBox(
          width: 8,
        ),
        Text("People", style: Theme.of(context).textTheme.subtitle2)
      ],
    );

    Widget horizontalLine = Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFF1F1F1),
          ),
        )
      ],
    );

    return ScreenBar(
      title,
      rightIcon: Icon(Ionicons.options_outline),
      bottom: PreferredSize(
        preferredSize: Size(0, 80),
        child: Center(
          child: Container(
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: subTitle),
                ),
                horizontalLine
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;
  final VoidCallback onTapCallback;

  static void defaultOnTapCallback() {}

  UserRow(this.user, {this.onTapCallback = defaultOnTapCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(8),
            child: GestureDetector(
                onTap: onTapCallback,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                            user.profile?.name ??
                                ArgumentError("Shouldn't be null profile")
                                    as String,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.headline2)),
                  ],
                ))));
  }
}
