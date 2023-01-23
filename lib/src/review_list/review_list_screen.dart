import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../photo_list/index.dart';
import '../repository/model/review.dart';
import '../view/gallery_photo_view.dart';
import 'package:intl/intl.dart';

import '../screen_arguments.dart';

class ReviewListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReviewListPageArguments args =
        ModalRoute.of(context)!.settings.arguments as ReviewListPageArguments;

    final List<Review> _reviews = args.reviews;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
            itemCount: args.reviews.length,
            separatorBuilder: (context, index) => SizedBox(
                  height: 32,
                ),
            itemBuilder: (context, index) => _ReviewTile(_reviews[index])));
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile(this.review);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 16),
        _avatar(review.userPhoto!, isFriend: review.isFriend ?? false),
        SizedBox(width: 16),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(context),
            SizedBox(height: 8),
            _body(review.comment!, context),
            SizedBox(height: 16),
            _gallery(review.photos)
          ],
        )),
      ],
    );
  }

  //region Widgets--------------------------------------------------------------
  Widget _avatar(String imgUrl, {bool isFriend = false}) {
    Widget icon = Positioned(
      top: 0,
      left: 6,
      child: SvgPicture.asset("assets/icon/ic_friend.svg"),
    );

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        ClipOval(
          child: Container(
            width: 64,
            height: 64,
            decoration: isFriend
                ? BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFC1E772), Color(0xFF8DCA3E)]))
                : null,
            padding: EdgeInsets.all(2.5),
            child: ClipOval(
              child: Image.network(imgUrl),
            ),
          ),
        ),
        isFriend ? icon : SizedBox()
      ],
    );
  }

  Widget _header(context) {
    Widget name =
        Text(review.userName!, style: Theme.of(context).textTheme.headline2);

    Widget rating = Text(
      '${review.reviewRatings!.overall}',
      style: Theme.of(context).textTheme.headline2,
    );

    Widget date = Text('${DateFormat.yMMMMd().format(review.dateCreated!)}',
        style: Theme.of(context).textTheme.headline4);

    return Container(
      padding: EdgeInsets.only(right: 16),
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
              rating
            ],
          ),
          SizedBox(height: 4),
          date
        ],
      ),
    );
  }

  Widget _body(String content, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ExpandableText(content,
            expandText: 'show more',
            collapseText: 'show less',
            maxLines: 7,
            linkColor: Color.fromARGB(255, 51, 69, 169),
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText1));
  }

  Widget _gallery(List<String>? photos) {
    photos ??= [];
    return Container(
      height: photos.length > 0 ? 64 : 0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: photos?.length != null
              ? photos.length > 4
                  ? photos.length + 1
                  : photos.length
              : 0,
          itemBuilder: (context, index) {
            return index == photos!.length
                ? _seeAll(photos)
                : _photo(photos[index], index);
          }),
    );
  }

  Widget _photo(String url, int index) {
    return Container(
        width: 64,
        margin: EdgeInsets.only(right: 12),
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => _navigateGalleryPhotoViewWrapper(context, index, url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
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
        onTap: () => _navigatePhotoList(photos, context),
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

  //region Navigation ----------------------------------------------------------
  _navigatePhotoList(List<String>? photoUrls, context) {
    Navigator.pushNamed(context, PhotoListPage.routeName,
        arguments: PhotoListPageArguments(photoUrls));
  }

  _navigateGalleryPhotoViewWrapper(BuildContext context, index, photo) {
    open(
        context,
        index,
        {photo}
            .map((url) => GalleryItem(id: '$index', resource: url))
            .toList());
  }
  //endregion
}
