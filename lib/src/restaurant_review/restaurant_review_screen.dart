import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/review.dart';
import 'index.dart';
import '../utils.dart';
import '../view/gallery_photo_view.dart';
import '../view/restaurant.dart';
import 'widgets/wave_slider.dart';

class RestaurantReviewScreen extends StatefulWidget {
  const RestaurantReviewScreen({
    Key? key,
    required Restaurant restaurant,
    required RestaurantReviewBloc restaurantReviewBloc,
  })  : _restaurantReviewBloc = restaurantReviewBloc,
        _restaurant = restaurant,
        super(key: key);

  final RestaurantReviewBloc _restaurantReviewBloc;
  final Restaurant _restaurant;

  @override
  RestaurantReviewScreenState createState() {
    return RestaurantReviewScreenState(_restaurantReviewBloc, _restaurant);
  }
}

class RestaurantReviewScreenState extends State<RestaurantReviewScreen> {
  final int MAX_UPLOAD_PHOTOS = 10;
  final RestaurantReviewBloc _restaurantReviewBloc;
  final Restaurant _restaurant;

  FocusNode? _focusNode;
  double _reviewScore = 3.5;
  TextEditingController? _textEditingController;
  List<XFile> _images = [];
  static final _textKey = GlobalKey<FormState>();

  RestaurantReviewScreenState(this._restaurantReviewBloc, this._restaurant);

  @override
  void initState() {
    super.initState();
    this._load();

    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  void onFocusChange() {
    if (_focusNode!.hasFocus) {
      // Hide sticker when keyboard appear
      // setState(() {
      //   isShowSticker = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantReviewBloc, RestaurantReviewState>(
        bloc: widget._restaurantReviewBloc,
        builder: (
          BuildContext context,
          RestaurantReviewState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              RestaurantReviewState currentState,
            ) {
              List<Widget> list = [_buildBody(context, _restaurant)];

              if (currentState is PostedRestaurantReviewState) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await ackDialog(
                          context, 'Successful', 'Review has been posted',
                          barrierDismissible: false)
                      .then((value) => Navigator.of(context).pop(true));
                });
                _load();
              }

              if (currentState is ErrorRestaurantReviewState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    _load();
                  });
                });
              }
              return WillPopScope(
                  onWillPop: _onBackPress,
                  child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: list));
            }));
  }

  //region Widgets -------------------------------------------------------------
  Widget _buildScoreSection() {
    return SizedBox(
      height: 110,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Overall score',
                    style: Theme.of(context).textTheme.subtitle1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _reviewScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headline1,
                ),
              )
            ],
          ),
          _slider(),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  Widget _slider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Text("0", style: Theme.of(context).textTheme.headline2),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: WaveSlider(
                sliderHeight: 60,
                color: Colors.grey[300],
//              value: _reviewScore,
//              min: 0.0,
//              max: 5.0,
                onChanged: (value) {
                  setState(() {
                    _reviewScore = toPrecision(value, 1);
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text("5", style: Theme.of(context).textTheme.headline2),
        ],
      ),
    );
  }

  Widget _addPhotosSection({required double width, required double height}) {
    Widget title = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        'Add photos (Optional)',
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );

    Widget gallery = Container(
        height: height,
        margin: EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + 1,
            itemBuilder: (BuildContext context, int index) {
              return index == _images.length
                  ? _addPhotoButton(index, width, height)
                  : _photoThumbnail(index, width.toInt(), height.toInt());
            }));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[title, gallery],
      ),
    );
  }

  Widget _addPhotoButton(int index, double width, double height) {
    return Padding(
        padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
        child: GestureDetector(
            onTap: () => _getImage(),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  width: width,
                  height: height,
                  color: Color(0xFFF1F1F1),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Color(0xFF3345A9),
                    ),
                  ),
                ),
              ),
            )));
  }

  Widget _photoThumbnail(int index, int width, int height) {
    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
      child: Center(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: GestureDetector(
                onTap: () => _navigateGalleryPhotoViewWrapper(
                    context, index, _images[index].name),
                child: Image.file(
                  File(_images[index].path),
                  width: width.toDouble(),
                  height: height.toDouble(),
                ),

                // AssetThumb(
                //     asset: _images[index], width: width, height: height)
              ))),
    );
  }

  Widget _commentSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How was your experience (Optional)',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              TextField(
                key: _textKey,
                textCapitalization: TextCapitalization.sentences,
                controller: _textEditingController,
                minLines: 1,
                maxLines: 5,
                maxLength: 1500,
                focusNode: _focusNode,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                    hintText: '1500 characters max.',
                    hintStyle: Theme.of(context).textTheme.bodyText1),
              )
            ]),
      ),
    );
  }

  Widget _submitButton(BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ButtonTheme(
          minWidth: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3345A9),
              shape: StadiumBorder(),
            ),
            child: Text("Submit review",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              _confirmSubmit(context, restaurant);
            },
          )),
    );
  }

  Widget _buildBody(BuildContext context, Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: RestaurantCard(
            restaurant,
            edgeInsets: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildScoreSection(),
        ),
        _addPhotosSection(width: 72, height: 72),
        _commentSection(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SafeArea(
                child: _submitButton(context, restaurant),
              )
            ],
          ),
        )
      ]),
    );
  }
  //endregion

  //region Private -------------------------------------------------------------
  Future<bool> _onBackPress() {
    // if (isShowSoftKeyboard) {
    //   setState(() {
    //     isShowSoftKeyboard = false;
    //   });
    // } else {
    //   Navigator.pop(context);
    // }
    return Future.value(true);
  }

  Future _getImage() async {
    try {
      List<XFile> resultList = await ImagePicker().pickMultiImage();

      // List<XFile> resultList = await MultiImagePicker.pickImages(
      //   maxImages: MAX_UPLOAD_PHOTOS,
      //   materialOptions: MaterialOptions(
      //     actionBarTitle: "Choose photos",
      //     allViewTitle: "All photos",
      //     actionBarColor:
      //         "#${Theme.of(context).cardColor.value.toRadixString(16)}",
      //     actionBarTitleColor:
      //         "#${Theme.of(context).textTheme.headline1!.color!.value.toRadixString(16)}",
      //     statusBarColor:
      //         "#${Theme.of(context).scaffoldBackgroundColor.value.toRadixString(16)}",
      //     lightStatusBar:
      //         MediaQuery.of(context).platformBrightness == Brightness.light,
      //   ),
      // );
      setState(() {
        _images = resultList;
      });
    } on Exception catch (e) {
      if (e.toString().toLowerCase() !=
          'the user has cancelled the selection') {
        widget._restaurantReviewBloc.add(ErrorRestaurantReviewEvent(e));
        return;
      }
    }
  }

  void _confirmSubmit(BuildContext context, Restaurant restaurant) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm to submit"),
            content: Text("Submit the review for this restaurant?"),
            actions: <Widget>[
              new TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("Cancel"),
              ),
              new TextButton(
                onPressed: () {
                  widget._restaurantReviewBloc.add(PostRestaurantReviewEvent(
                      restaurant,
                      Review(
                          comment: _textEditingController!.text,
                          reviewRatings:
                              ReviewRatings.withOneRating(_reviewScore)),
                      _images));
                  Navigator.of(context).pop();
                },
                child: new Text("Ok"),
              ),
            ],
          );
        });
  }

  void _load([bool isError = false]) {
    // widget._restaurantReviewBloc.add(UnRestaurantReviewEvent());
    widget._restaurantReviewBloc.add(LoadRestaurantReviewEvent(_restaurant));
  }

  _navigateGalleryPhotoViewWrapper(BuildContext context, index, String? photo) {
    open(
        context,
        index,
        Set.from([photo])
            .map((url) => GalleryItem(id: '$index', resource: url))
            .toList());
  }
  //endregion
}
