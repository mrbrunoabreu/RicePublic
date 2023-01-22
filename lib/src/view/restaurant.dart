import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:rice/src/repository/model/review.dart';
import 'package:rice/src/utils.dart';

import 'package:rice/src/view/gallery_photo_view.dart';

class RestaurantRow extends StatelessWidget {
  final Restaurant restaurant;
  final List<String> photos;
  final VoidCallback onTapCallback;

  List<GalleryItem> _galleryItems = [];

  static void defaultOnTapCallback() {}

  RestaurantRow(this.restaurant,
      {this.photos = const [], this.onTapCallback = defaultOnTapCallback});

  void buildGalleryItems() {
    _galleryItems = (photos?.isNotEmpty ?? []) as bool
        ? mapIndexed(
                photos, (index, dynamic p) => GalleryItem(id: '$index', resource: p))
            .toList()
        : [];
  }

  @override
  Widget build(BuildContext context) {
    buildGalleryItems();
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
                          restaurant.name!,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.headline2
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(right: 8, bottom: 4),
                                  child: Text(
                                    restaurant.address!,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: Theme.of(context).textTheme.headline4,
                                  ))),
                          restaurant.rating != null
                              ? Container(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.star,
                                        color: Color(0xFFF7C669),
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(restaurant.rating!.toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.subtitle2)
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: buildPhotos(context),
                    )
                  ],
                ))));
  }

  List<Widget> buildPhotos(BuildContext context) {
    if (_galleryItems.isEmpty) {
      return [
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(4),
            ))
      ];
    }

    return mapIndexed(
        _galleryItems.sublist(
            0, _galleryItems.length > 3 ? 3 : _galleryItems.length),
        (index, dynamic p) => Expanded(
              child: Container(
                  height: 80,
                  padding: const EdgeInsets.all(6.5),
                  child: GestureDetector(
                      onTap: () => open(context, index, _galleryItems),
                      child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8.0),
                          child: Image.network(
                            p.resource,
                            fit: BoxFit.cover,
                          )))),
            )).toList();
  }
}

class RestaurantGalleryRow extends StatelessWidget {
  final Restaurant restaurant;
  final List<String> photos;
  VoidCallback? tappedCallback = () {};

  static int photoCount = 432;

  RestaurantGalleryRow(this.restaurant, this.photos, {this.tappedCallback});

  @override
  Widget build(BuildContext context) {
    photoCount = photos.length;
    return Container(
        margin: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          child: Text(
                            'Gallery',
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subtitle1,
                          ))),
                  photoCount > 4
                      ? Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: tappedCallback,
                                  child: Text(
                                    'See all $photoCount photos >',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color:
                                            Color.fromARGB(255, 51, 69, 169)),
                                  )),
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            Container(
              height: 90 + 8.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    String photoUrl = photos[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 2, 8),
                      child: GestureDetector(
                        onTap: () => open(context, index,
                            [GalleryItem(id: '$index', resource: photoUrl)]),
                        child: ClipRRect(
                          borderRadius: new BorderRadius.circular(8.0),
                          child: Container(
                              width: 90,
                              height: 90,
                              child:
                                  Image.network(photoUrl, fit: BoxFit.cover)),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}

class RestaurantVisitedFriendsRow extends StatelessWidget {
  final Restaurant restaurant;
  VoidCallback? tappedCallback = () {};

  static const int photoCount = 0;
  static const int maxAvatarCount = 0;

  RestaurantVisitedFriendsRow(this.restaurant, {this.tappedCallback});

  _buildFriendsAvatars() {
    return <Widget>[].toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      'Friends who have visited',
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.headline2,
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // Expanded(
                      //     child:
                      Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Row(
                            children: _buildFriendsAvatars(),
                          )),
                      // ),
                      Container(
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                                onTap: tappedCallback,
                                child: Text(
                                  '+ $photoCount more',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.button,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}

class RestaurantReviewsRow extends StatelessWidget {
  final Restaurant restaurant;
  final List<Review> reviews;
  VoidCallback? tappedAllCallback = () {};
  VoidCallback? tappedAddReviewCallback = () {};
  bool enableAddingReview;

  static int reviewCount = 17;

  RestaurantReviewsRow(this.restaurant, this.reviews,
      {this.enableAddingReview = true,
      this.tappedAllCallback,
      this.tappedAddReviewCallback});

  _buildReviewAvatar(String url) {
    return Padding(
        padding: EdgeInsets.only(right: 8),
        child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              url,
            )));
  }

  _buildReviews(List<Review> reviews, BuildContext context) {
    return Column(
      children: reviews.map((review) => _buildReview(review, context)).toList(),
    );
  }

  Widget _buildReview(Review review, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Row(
                children: [_buildReviewAvatar(review.userPhoto!)],
              )),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(right: 48),
                                child: Text(
                                  review.userName!,
                                  // (id == 0) ? 'Stynebrenner12' : 'Maxxx_22',
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.subtitle2,
                                )),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: Color(0xFFF7C669),
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text('${review.reviewRatings!.overall}',
                                      style: Theme.of(context).textTheme.subtitle2
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              review.comment!,
                              // (id == 0)
                              //     ? 'I absolutely loved this place, the food is fresh and the magaritas are trying the pulled pork tacos. Amazing flavours'
                              //     : 'Highly recommend trying the pulled pork tacos. Amazing flavoursHighly recommend trying the pulled pork tacos. Amazing flavours',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText1
                              // )
                            )),
                      ]))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    reviewCount = reviews.length;
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
                                'Reviews',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.subtitle1,
                              ))),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                                onTap: tappedAllCallback,
                                child: Text(
                                  'See all $reviewCount reviews >',
                                  style: Theme.of(context).textTheme.button,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // _buildReview(reviews),
                // _buildReview(1),
                _buildReviews(reviews, context),
                Container(
                  alignment: AlignmentDirectional.centerEnd,
                  child: enableAddingReview
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          child: GestureDetector(
                              onTap: tappedAddReviewCallback,
                              child: Text(
                                '+ Add a review',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.button,
                              )),
                        )
                      : null,
                ),
              ],
            )));
  }
}

Widget buildRestaurant(Restaurant restaurant, VoidCallback callback, BuildContext context) {
  return SizedBox(
      width: 188.0,
      child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 8),
          child: GestureDetector(
              onTap: callback,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: restaurant.photo == null
                        ? buildPlaceholderImage()
                        : Image.network(
                            restaurant.photo!,
                            height: 100.0,
                            width: 172.0,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Text(
                    restaurant.name!,
                    style: Theme.of(context).textTheme.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    restaurant.address != null ? restaurant.address! : '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headline4
                  ),
                ],
              ))));
}

Widget buildPlaceholderImage() {
  return Center(
    child: Container(
      child: SvgPicture.asset(
        'assets/icon/ic_rice_logo.svg',
        width: 56,
        height: 56,
      ),
    ),
  );
}

Widget buildImage({double? width, double? height, String? url}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: CachedNetworkImage(
      imageUrl: url ?? '',
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      placeholder: (context, url) => buildPlaceholderImage(),
      errorWidget: (context, url, error) => buildPlaceholderImage(),
    ),
  );
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final double width;
  final double height;
  final EdgeInsets edgeInsets;

  RestaurantCard(this.restaurant,
      {this.width = 350.0,
      this.height = 140.0,
      this.edgeInsets = const EdgeInsets.only(left: 16, bottom: 16)});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        padding: edgeInsets,
        child: Center(
          child: Card(
            elevation: 4.0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _photo(),
                    Expanded(
                      child: _info(context),
                    ),
                  ],
                )),
          ),
        ));
  }

  Widget _photo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: buildImage(
        width: 80,
        height: 80,
        url: restaurant.photo,
      ),
    );
  }

  Widget _info(context) {
    Widget name = Text(
      restaurant.name!,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.subtitle2,
    );

    Widget address = Text(
      restaurant.address!,
      maxLines: 3,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headline4,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[name, SizedBox(height: 8), address]),
    );
  }
}
