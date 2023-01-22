import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:rice/src/photo_list/index.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:rice/src/repository/model/review_comment.dart';
import 'package:rice/src/repository/model/timeline_reviews.dart';
import 'package:rice/src/restaurant_detail/index.dart';
import 'package:rice/src/utils.dart';
import 'package:rice/src/view/gallery_photo_view.dart';
import 'package:ionicons/ionicons.dart';
import 'package:expandable_text/expandable_text.dart';

import '../screen_arguments.dart';
import 'dart:developer' as developer;

class MealTimelineScreen extends StatelessWidget {
  final List<TimelineReview> reviews;
  MealTimelineScreen(this.reviews);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (context, index) => SizedBox(
                  height: 32,
                ),
            itemBuilder: (context, index) =>
                ReviewTile(key: GlobalKey(), review: reviews[index])));
  }
}

// ignore: must_be_immutable
class ReviewTile extends StatefulWidget {
  final TimelineReview? review;
  final bool isFullStyle;
  ValueCallback<bool, Future<bool?>>? _likeCallback;
  VoidCallback? _commentCallback;

  ReviewTile({
    Key? key,
    this.review,
    ValueCallback<bool, Future<bool>>? likeCallback = null,
    VoidCallback? commentCallback = null,
    this.isFullStyle = true,
  }) : super(key: key) {
    this._likeCallback = likeCallback;
    this._commentCallback = commentCallback;
  }

  setLikeCallback(ValueCallback<bool, Future<bool?>> callback) {
    this._likeCallback = callback;
  }

  setCommentCallback(VoidCallback callback) {
    this._commentCallback = callback;
  }

  @override
  State<StatefulWidget> createState() => ReviewTileState(
        review: review,
        isFullStyle: isFullStyle,
      );
}

class ReviewTileState extends State<ReviewTile>
    with SingleTickerProviderStateMixin {
  static final String TAG = "ReviewTile";
  final TimelineReview? review;
  final bool isFullStyle;

  bool? isLiked = false;

  late AnimationController _controller;

  ReviewTileState({this.review, this.isFullStyle = true});

  @override
  void initState() {
    super.initState();
    isLiked = review!.review!.likes!.contains(review!.currentUserId);
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _review(context);
  }

  //region Widgets--------------------------------------------------------------
  Widget _review(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _avatar(context, review!.user?.profile?.picture?.url ?? "",
                  review!.isFollowing),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[_header(context), SizedBox(height: 8)],
              )),
            ],
          ),
          SizedBox(height: 8),
          _gallery(review!.review!.photos, deviceWidth),
          SizedBox(height: 10),
          _body(review!.review!.comment!, context),
          SizedBox(height: 8),
          _likesAndComments(isLiked!),
          if (isFullStyle) _lastestComments(),
          SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context, String imgUrl, bool isFollowing) {
    if (isFollowing) {
      Widget icon = Positioned(
        bottom: 0,
        right: 0,
        child: SvgPicture.asset(
          "assets/icon/ic_friend.svg",
        ),
      );

      return Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          ClipOval(
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFC1E772), Color(0xFF8DCA3E)])),
              padding: EdgeInsets.all(2.5),
              child: ClipOval(
                child: imgUrl.isNotEmpty ? Image.network(imgUrl) : Container(),
              ),
            ),
          ),
          icon
        ],
      );
    }
    return Container(
      width: 45,
      height: 45,
      padding: EdgeInsets.all(2.5),
      child: ClipOval(
        child: imgUrl.isNotEmpty ? Image.network(imgUrl) : Container(),
      ),
    );
  }

  Widget _header(context) {
    Widget name = Text(review!.user?.profile?.name ?? "",
        style: Theme.of(context).textTheme.subtitle2);

    Widget rating = Text(
      '${review!.review!.reviewRatings!.overall}',
      style: Theme.of(context).textTheme.headline2,
    );

    Widget restaurantName = GestureDetector(
      onTap: () => _navigateRestaurantDetail(context, review!.restaurant),
      child: Text(review!.restaurant?.name ?? "",
          style: Theme.of(context).textTheme.bodyText1),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: name,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.star,
                color: Color(0xFFF7C669),
                size: 16,
              ),
              SizedBox(width: 4),
              rating
            ],
          ),
          restaurantName
        ],
      ),
    );
  }

  Widget _body(String content, BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: ExpandableText(content,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: 7,
            linkColor: Theme.of(context).textSelectionTheme.selectionColor,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText1));
  }

  Widget _gallery(List<String>? photos, double deviceWidth) {
    photos ??= [];
    if (photos.isNotEmpty) {
      return Column(
        children: [
          Container(
            height: (isFullStyle && photos.length > 0) ? 300 : 0,
            width: photos.length > 0 ? deviceWidth : 0,
            child: _mainPhoto(photos[0], 0, deviceWidth, photos),
          ),
          SizedBox(
            height: 8,
          ),
          if (photos.length > 1)
            Container(
              height: photos.length > 0 ? 64 : 0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length >
                          5 // Showing maximum 5 photos (1 main + 4 minor)
                      ? photos.length
                      : photos.length - 1,
                  itemBuilder: (context, index) {
                    return index ==
                            photos!.length - 1 // Minus 1 because of main photo
                        ? _seeAll(photos)
                        : _photo(photos[index + 1], index + 1, photos);
                  }),
            ),
        ],
      );
    }
    return Container();
  }

  Widget _photo(String url, int index, List<String>? photos) {
    return Container(
        width: 64,
        margin: EdgeInsets.only(right: 8),
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () =>
                _navigateGalleryPhotoViewWrapper(context, index, photos!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.grey,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _mainPhoto(
      String url, int index, double deviceWidth, List<String> photos) {
    if (!isFullStyle) {
      return Container();
    }
    return Container(
        width: deviceWidth,
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () =>
                _navigateGalleryPhotoViewWrapper(context, index, photos),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.grey,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _seeAll(List<String>? photos) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () => _navigatePhotoList(context, photos),
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            "See all >",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Color.fromARGB(255, 51, 69, 169)),
          ),
        ),
      );
    });
  }
  //endregion

  Widget _likesAndComments(bool isLiked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // if (_controller.isCompleted) {
            //   _controller.reverse();
            // } else {
            //   _controller.forward();
            // }
            if (widget._likeCallback != null) {
              widget._likeCallback!(!isLiked).then((value) {
                setState(() {
                  this.isLiked = value;
                });
              });
            }
          },
          child: Stack(children: <Widget>[
            Container(
                padding: EdgeInsets.all(0),
                child: isLiked
                    ? Icon(Ionicons.heart,
                        size: 26, color: const Color(0xFFFF1F5F))
                    : Icon(Ionicons.heart_outline, size: 26)),
            // Container(
            //   // color: Colors.black,
            //   padding: EdgeInsets.only(top: 4),
            //   child: Lottie.asset('assets/animation/like-heart-animation.json',
            //   width: 26,
            //   height: 26,
            //   fit: BoxFit.fitHeight,
            //   repeat: false,
            //   controller: _controller,
            //   onLoaded: (composition) {
            //         _controller
            //           ..duration = composition.duration;
            //         developer.log("${review.review.likes} and ${review.currentUserId}", name: TAG);
            //         review.review.likes.contains(review.currentUserId)?
            //           _controller.forward()
            //           :
            //           _controller.reset();
            //         _controller
            //           ..addStatusListener((status) {
            //           // if (status == AnimationStatus.completed) {
            //           //   developer.log("AnimationStatus.completed", name: TAG);
            //           // }
            //           // if (status == AnimationStatus.dismissed) {
            //           //   developer.log("AnimationStatus.dismissed", name: TAG);
            //           // }
            //           if (status == AnimationStatus.forward) {
            //             // developer.log("AnimationStatus.forward", name: TAG);
            //             if (widget._likeCallback != null) {
            //               widget._likeCallback(true);
            //             }
            //           }
            //           if (status == AnimationStatus.reverse) {
            //             // developer.log("AnimationStatus.reverse", name: TAG);
            //             if (widget._likeCallback != null) {
            //               widget._likeCallback(false);
            //             }
            //           }
            //         });
            //       },
            //   ),
            // ),
          ]),
        ),
        SizedBox(width: 15),
        GestureDetector(
            child: Icon(Ionicons.chatbubble_outline, size: 23),
            onTap: () {
              if (widget._commentCallback != null) {
                widget._commentCallback!();
              }
            })
      ],
    );
  }

  _lastestComments() {
    if (review!.futureReviewComments != null)
      return FutureBuilder<List<ReviewCommentWithUser>>(
          future: review!.futureReviewComments
              ?.then((value) => value as List<ReviewCommentWithUser>),
          builder: (BuildContext context,
              AsyncSnapshot<List<ReviewCommentWithUser>> snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return Container();
            String userName = snapshot.data![0].user?.profile?.name ?? '';
            // developer.log(snapshot.data.toString(), name: TAG);
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "${userName}: ",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Expanded(
                        child: Text(
                          "${snapshot.data![0].comment}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ],
                  ),
                  if (snapshot.data!.length > 1)
                    GestureDetector(
                        onTap: () {
                          if (widget._commentCallback != null) {
                            widget._commentCallback!();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child:
                              Text("View all ${snapshot.data!.length} comments",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Theme.of(context).buttonColor,
                                  )),
                        ))
                ],
              ),
            );
          });
  }

  //region Navigation ----------------------------------------------------------
  _navigatePhotoList(BuildContext context, List<String>? photoUrls) {
    Navigator.pushNamed(context, PhotoListPage.routeName,
        arguments: PhotoListPageArguments(photoUrls));
  }

  _navigateGalleryPhotoViewWrapper(
      BuildContext context, index, List<String> photos) {
    open(context, index,
        photos.map((url) => GalleryItem(id: '$index', resource: url)).toList());
  }

  _navigateRestaurantDetail(BuildContext context, Restaurant? restaurant) {
    Navigator.pushNamed(context, RestaurantDetailPage.routeName,
        arguments: RestaursntDetailPageArguments(restaurant));
  }
  //endregion
}
