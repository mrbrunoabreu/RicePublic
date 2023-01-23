import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../base_bloc.dart';
import '../explore/index.dart';
import '../explore_plans/explore_plans_page.dart';
import '../meal_timeline_sketch/meal_timeline_screen_sketch.dart';
import '../notification/index.dart';
import '../personal_lists/personal_lists_page.dart';
import '../repository/model/plan.dart';
import '../post/index.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/timeline_reviews.dart';
import '../restaurant_detail/index.dart';
import '../restaurant_list/index.dart';
import '../review_comments/index.dart';
import '../search_result/search_result_page.dart';
import '../view/home_bar.dart';
import '../view/plan.dart';
import '../view/restaurant.dart';
import '../view/top_banner.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tuple/tuple.dart';

import '../screen_arguments.dart';
import '../utils.dart';

import 'dart:developer' as developer;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    Key? key,
    required ExploreBloc exploreBloc,
  })  : _exploreBloc = exploreBloc,
        super(key: key);

  final ExploreBloc _exploreBloc;

  @override
  ExploreScreenState createState() {
    return ExploreScreenState(_exploreBloc);
  }
}

class ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ExploreBloc _exploreBloc;
  final List<Tab> searchTabs = <Tab>[
    Tab(text: 'Restaurant'),
    Tab(text: 'People'),
  ];

  PanelController _pc = new PanelController();
  TabController? _tabController;
  ScrollController? _scrollController;
  late RefreshController _refreshController;
  AnimationController? _animationController;
  ExploreScreenState(this._exploreBloc);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    this._load();
    _tabController = TabController(vsync: this, length: searchTabs.length);
    _scrollController = ScrollController()..addListener(_scrollListener);
    _refreshController = RefreshController(initialRefresh: false);
    _animationController = AnimationController(
      vsync: this,
    );
  }

  void _onRefresh() async {
    widget._exploreBloc.add(LoadExploreEvent(refresh: true));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController!.dispose();
    _scrollController!.dispose();
    _refreshController.dispose();
    _animationController!.dispose();
    _exploreBloc.add(UnExploreEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(
          Duration(milliseconds: 1500),
          () => _load(),
        );
      });
    }
    if (state == AppLifecycleState.paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(
          Duration(milliseconds: 500),
          () => widget._exploreBloc.add(UnExploreEvent()),
        );
      });
    }
  }

  Future<bool> _onWillPop() {
    if (!_pc.isPanelClosed) {
      _pc.close();
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _scrollListener() {
    if (_scrollController!.position.pixels ==
        _scrollController!.position.maxScrollExtent) {
      developer.log("Require more data", name: 'ExploreScreenState');
      _exploreBloc.add(LoadExploreEvent(loadMore: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
        bloc: widget._exploreBloc,
        builder: (
          BuildContext context,
          ExploreState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              ExploreState currentState,
            ) {
              List<Widget> list = [buildSlidingUpPanel(context, currentState)];

              if (currentState is ErrorExploreState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    widget._exploreBloc.add(UnExploreEvent());
                  });
                });
              }
              return WillPopScope(
                  onWillPop: _onWillPop, child: Stack(children: list));
            }));
  }

  Widget _buildTimelineReviewItem(TimelineReview review) {
    return ReviewTile(key: GlobalKey(), review: review)
      ..setCommentCallback(() {
        navigateReviewComment(review);
      })
      ..setLikeCallback((value) async {
        bool? result =
            await widget._exploreBloc.toggleLikeReview(review.review!.id);
        return result;
      });
  }

  Widget _buildNoResult() {
    return SmartRefresher(
        controller: _refreshController,
        header: MaterialClassicHeader(),
        onRefresh: _onRefresh,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(right: 36),
                child: Lottie.asset(
                  'assets/animation/no-review-animation.json',
                  width: 180,
                  height: 180,
                  fit: BoxFit.fitHeight,
                  repeat: true,
                  controller: _animationController,
                  onLoaded: (composition) {
                    _animationController
                      ?..duration = composition.duration
                      ..forward()
                      ..repeat();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24, top: 16),
                child: Text("Follow some people to get started",
                    style: Theme.of(context).textTheme.subtitle1),
              ),
            ],
          ),
        ));
  }

  Widget _body(ExploreState currentState) {
    if (currentState is InExploreState) {
      List<Plan>? plans = currentState.props != null
          ? currentState.props
              .firstWhere((test) => test.item3 == ExploreState.plans,
                  orElse: () =>
                      Tuple4(ExploreState.plans, const <Plan>[], null, null))
              .item4
          : [];
      return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Container(
              margin: const EdgeInsets.only(bottom: 138),
              child: StreamBuilder<List<TimelineReview>>(
                stream: currentState.subscription.getReviews(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<TimelineReview>> snapshot) {
                  if (!snapshot.hasData) return _buildNoResult();
                  final int cardLength = snapshot.data!.length;
                  if (snapshot.data!.length == 0) {
                    developer.log("snapshot.data.length = 0",
                        name: "ExploreScreenState");
                    return const Text('No more data');
                  }
                  developer.log("snapshot.data.length = $cardLength + 1",
                      name: "ExploreScreenState");
                  return SmartRefresher(
                      controller: _refreshController,
                      header: MaterialClassicHeader(),
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: cardLength + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 2) {
                            return _exploreSection(
                              'Nearby Plans',
                              '',
                              220,
                              plans!
                                  .map((plan) =>
                                      _plan(context, plan, plans.indexOf(plan)))
                                  .toList(),
                              () {
                                Navigator.of(context).pushNamed(
                                  ExplorePlansPage.routeName,
                                  arguments: ExplorePlansPageArguments(
                                      title: 'Nearby Plans'),
                                );
                              },
                            );
                          }
                          // if (index < snapshot.data!.length)
                          return _buildTimelineReviewItem(
                              snapshot.data![(index > 2) ? index - 1 : index]);
                        },
                      ));
                },
              )));
    }
    return Container();
  }

  // #region Prior Explore body
  // Widget _body_(ExploreState currentState) => LayoutBuilder(
  //         builder: (BuildContext context, BoxConstraints viewportConstraints) {
  //       List<Restaurant> restaurants = currentState.props != null
  //           ? currentState.props
  //               .firstWhere((test) => test.item1 == ExploreState.restaurants,
  //                   orElse: () => Tuple4(ExploreState.restaurants,
  //                       const <Restaurant>[], null, null))
  //               .item2
  //           : [];

  //       List<Plan> plans = currentState.props != null
  //           ? currentState.props
  //               .firstWhere((test) => test.item3 == ExploreState.plans,
  //                   orElse: () =>
  //                       Tuple4(ExploreState.plans, const <Plan>[], null, null))
  //               .item4
  //           : [];
  //       return SafeArea(
  //                 child: Container(
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           child: CustomScrollView(slivers: <Widget>[
  //             SliverToBoxAdapter(
  //                 child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: <Widget>[
  //                 TopBanner(
  //                   height: 200.0,
  //                   horizontalPadding: 8,
  //                   elevation: 4,
  //                   onTap: (String id) => navigatePost(id),
  //                   children:
  //                       currentState != null && currentState is InExploreState
  //                           ? currentState.latestPosts
  //                           : [],
  //                 ),

  //                 // ElevatedButton(
  //                 //   child: Text('Find plans around you'),
  //                 //   color: Color.fromARGB(125, 245, 245, 245),
  //                 //   elevation: 1,
  //                 //   onPressed: () {
  //                 //     //Do something
  //                 //   },
  //                 // ),
  //               ],
  //             )),
  //             SliverToBoxAdapter(
  //               child: _exploreSection(
  //                 'Nearby Plans',
  //                 '',
  //                 220,
  //                 plans
  //                     .map((plan) => _plan(context, plan, plans.indexOf(plan)))
  //                     .toList(),
  //                 () {
  //                   Navigator.of(context).pushNamed(
  //                     ExplorePlansPage.routeName,
  //                     arguments: ExplorePlansPageArguments(title: 'Nearby Plans'),
  //                   );
  //                 },
  //               ),
  //             ),
  //             SliverToBoxAdapter(
  //               child: _exploreSection(
  //                 'Recommended for you',
  //                 '',
  //                 220,
  //                 restaurants
  //                     .map(
  //                       (restaurant) => buildRestaurant(
  //                         restaurant,
  //                         () => navigateRestaurantDetail(restaurant), context
  //                       ),
  //                     )
  //                     .toList(),
  //                 () {
  //                   navigateRestaurantList(restaurants);
  //                 },
  //                 emptyMessage: 'No Restaurants',
  //               ),
  //             ),
  //             SliverToBoxAdapter(
  //               child: _exploreSection(
  //                 'Friends Plans',
  //                 '',
  //                 220,
  //                 plans
  //                     .map((plan) => _plan(context, plan, plans.indexOf(plan)))
  //                     .toList(),
  //                 () {
  //                   Navigator.of(context).pushNamed(
  //                     ExplorePlansPage.routeName,
  //                     arguments: ExplorePlansPageArguments(
  //                       title: 'Friends Plans',
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //             SliverToBoxAdapter(
  //               child: _exploreSection(
  //                 'Popular lists',
  //                 '',
  //                 220,
  //                 [], // restaurants.map((r) => buildList(r, 220)).toList(),
  //                 () {
  //                   Navigator.of(context).pushNamed(
  //                     PersonalListsPage.routeName,
  //                     arguments: PersonalListsPageArguments(
  //                       name: 'Popular Lists',
  //                       readonly: true,
  //                     ),
  //                   );
  //                 },
  //                 emptyMessage: 'No Lists',
  //               ),
  //             ),
  //             SliverToBoxAdapter(
  //               child: SizedBox(
  //                 height: 128,
  //               ),
  //             )
  //           ]),
  //         ),
  //       );
  //     });

  Widget _exploreSection(String title, String namedRoute, double height,
      List<Widget> children, void onSeeAllClicked(),
      {String? emptyMessage}) {
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                GestureDetector(
                  onTap: onSeeAllClicked,
                  child: Row(
                    children: <Widget>[
                      Text(
                        'See All',
                        style: Theme.of(context).textTheme.button,
                      ),
                      Icon(Icons.keyboard_arrow_right,
                          color: Theme.of(context).buttonColor)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height: 160,
              child: children.length > 0
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: children,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.info,
                          size: 30,
                        ),
                        Text(
                          emptyMessage ?? 'No Plans',
                          style: Theme.of(context).textTheme.headline6,
                        )
                      ],
                    )),
        ],
      ),
    );
  }

  Widget _plan(BuildContext context, plan, int index) {
    return buildPlan(context, plan,
        paddingLeft: index == 0 ? 12 : 4, paddingRight: 8);
  }
  // #endregion

  void _load([bool refresh = false]) {
    widget._exploreBloc.add(UnExploreEvent());
    widget._exploreBloc.add(LoadExploreEvent(refresh: refresh));
  }

  Widget buildSlidingUpPanel(BuildContext context, ExploreState currentState) {
    BorderRadiusGeometry radius = BorderRadius.only(
      bottomLeft: Radius.circular(16.0),
      bottomRight: Radius.circular(16.0),
    );
    const double elevation = 8;

    final _kewordTextController = TextEditingController();

    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    var slidingUpPanel = SlidingUpPanel(
      color: Theme.of(context).backgroundColor,
      controller: _pc,
      minHeight: 0,
      maxHeight: 210,
      backdropEnabled: true,
      slideDirection: SlideDirection.DOWN,
      panel: Center(
        child: Container(
            margin: EdgeInsets.all(8),
            child: SafeArea(
                child: Column(children: <Widget>[
              TabBar(
                  controller: _tabController,
                  indicatorColor:
                      Theme.of(context).textSelectionTheme.selectionColor,
                  labelColor: isDarkMode ? Colors.white : Colors.black,
                  labelStyle: Theme.of(context).textTheme.bodyText2,
                  tabs: searchTabs),
              SizedBox(height: 8),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.circular(15.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        TextField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _kewordTextController,
                          decoration: InputDecoration(
                              hintText: "Search with a keyword",
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search,
                                  color: Theme.of(context).hintColor),
                              suffixIcon: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Icon(Ionicons.options_outline,
                                      color: Theme.of(context).hintColor)

                                  // SvgPicture.asset(
                                  //     "assets/icon/ic_filter.svg",
                                  //     color: Color(0xFF3345A9))
                                  )),
                        ),
                      ],
                    ),
                  )),
              // Padding(
              //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              //     child: Material(
              //       elevation: elevation,
              //       borderRadius: BorderRadius.circular(15.0),
              //       child: TextField(textCapitalization: TextCapitalization.sentences,
              //         controller: _placeTextController,
              //         decoration: InputDecoration(
              //             hintText: "Places around me",
              //             hintStyle: TextStyle(color: Color(0XFFAAAAAA)),
              //             border: InputBorder.none,
              //             prefixIcon: Icon(MaterialCommunityIcons.map,
              //                 color: Color(0XFFAAAAAA)),
              //             suffixIcon: GestureDetector(
              //               onTap: () async {
              //                 Geolocator().getCurrentPosition();
              //               },
              //               child: Padding(
              //                 padding: EdgeInsets.all(12),
              //                 child: SvgPicture.asset(
              //                   'assets/icon/ic_explore_active.svg',
              //                   width: 24,
              //                   height: 24,
              //                   allowDrawingOutsideViewBox: false,
              //                 ),
              //               ),
              //             )),
              //       ),
              //     )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ButtonTheme(
                    minWidth: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        shape: StadiumBorder(),
                      ),
                      child: Text("Search",
                          style: Theme.of(context).textTheme.subtitle2),
                      onPressed: () {
                        // developer.log('Current tab is ' + _tabController.index.toString());
                        if (_kewordTextController.text != null &&
                            _kewordTextController.text.isNotEmpty) {
                          if (_tabController!.index == 0) {
                            navigateSearchResult(
                                _kewordTextController.text,
                                (currentState as InExploreState).currentLat,
                                currentState.currentLng);
                          } else {
                            navigatePeopleSearchResult(
                                _kewordTextController.text,
                                (currentState as InExploreState).currentLat,
                                currentState.currentLng);
                          }
                        } else {
                          // TODO: Place search
                        }
                      },
                    )),
              ),
              // Padding(
              //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              //     child: GestureDetector(
              //         onTap: () => () {},
              //         child: Row(
              //             mainAxisSize: MainAxisSize.max,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               SvgPicture.asset("assets/icon/ic_restaurant.svg",
              //                   color: Color(0xFF3345A9)),
              //               SizedBox(width: 8),
              //               Text(
              //                 'Browse by cuisine',
              //                 style: TextStyle(
              //                     fontSize: 14,
              //                     color: Color(0xFF3345A9),
              //                     fontWeight: FontWeight.bold),
              //               )
              //             ]))),
            ]))),
      ),
      backdropColor: Colors.black,
      body: _body(currentState),
      borderRadius: radius,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: HomeBar(
          leftIconTapCallback: () {
            Navigator.pushNamed(context, NotificationPage.routeName);
          },
          rightIconTapCallback: () {
            if (!_pc.isPanelClosed) {
              _pc.close();
              _exploreBloc.add(LoadExploreEvent());
            } else {
              _pc.open();
            }
          },
        ),
      ),
      body: slidingUpPanel,
    );
  }

  navigateRestaurantDetail(Restaurant restaurant) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, RestaurantDetailPage.routeName,
          arguments: RestaursntDetailPageArguments(restaurant));
    });
  }

  navigateRestaurantList(List<Restaurant> restaurants) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, RestaurantListPage.routeName,
          arguments: RestaurantListPageArguments(restaurants));
    });
  }

  navigateSearchResult(String keyword, double currentLat, double currentLng) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, SearchResultPage.routeName,
          arguments: SearchResultPageArguments(
              KeywordSearchArguments(keyword, currentLat, currentLng)));
    });
  }

  navigatePeopleSearchResult(
      String keyword, double currentLat, double currentLng) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, SearchResultPage.routeName,
          arguments: SearchResultPageArguments(
              PeopleSearchArguments(keyword, currentLat, currentLng)));
    });
  }

  navigatePost(String id) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, PostPage.routeName,
          arguments: PostPageArguments(id));
    });
  }

  navigateReviewComment(TimelineReview review) {
    _pc.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, ReviewCommentsPage.routeName,
          arguments: ReviewCommentsPageArguments(review: review));
    });
  }
}
