import 'dart:async';
import 'package:animated_stream_list_nullsafety/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../meal_timeline_sketch/meal_timeline_screen_sketch.dart';
import '../repository/model/review_comment.dart';
import '../repository/model/timeline_reviews.dart';
import '../repository/model/user.dart';
import '../review_comments/index.dart';
import '../view/user_avatar.dart';
import '../base_bloc.dart';
import '../utils.dart';

import 'package:timeago/timeago.dart' as timeago;

class ReviewCommentsScreen extends StatefulWidget {
  const ReviewCommentsScreen({
    Key? key,
    required TimelineReview review,
    required ReviewCommentsBloc reviewCommentsBloc,
  })  : _reviewCommentsBloc = reviewCommentsBloc,
        _review = review,
        super(key: key);

  final ReviewCommentsBloc _reviewCommentsBloc;
  final TimelineReview _review;

  @override
  ReviewCommentsScreenState createState() {
    return ReviewCommentsScreenState(_reviewCommentsBloc, _review);
  }
}

class ReviewCommentsScreenState extends State<ReviewCommentsScreen>
    with WidgetsBindingObserver {
  final ReviewCommentsBloc _reviewCommentsBloc;
  final TimelineReview _review;
  final FocusNode focusNode = new FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController scroll2 = ScrollController();
  final TextEditingController textMessageController =
      new TextEditingController(text: '');

  ReviewCommentsScreenState(this._reviewCommentsBloc, this._review);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    this._load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reviewCommentsBloc.add(UnReviewCommentsEvent());
    focusNode.unfocus();
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
          () => widget._reviewCommentsBloc.add(UnReviewCommentsEvent()),
        );
      });
    }
  }

  Future<bool> _onBackPress() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCommentsBloc, ReviewCommentsState>(
        bloc: widget._reviewCommentsBloc,
        builder: (
          BuildContext context,
          ReviewCommentsState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              ReviewCommentsState currentState,
            ) {
              if (currentState is ErrorReviewCommentsState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }

              if (currentState is InReviewCommentsState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // _loadUrl(currentState..url);
                  //_loadHtml(currentState.post.html);
                });
              }

              return WillPopScope(
                onWillPop: _onBackPress,
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    Scaffold(
                      appBar: _appBar() as PreferredSizeWidget?,
                      body: _body(currentState),
                      floatingActionButton: _buildInput(state: currentState),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.miniCenterFloat,
                    )
                  ],
                ),
              );
            }));
  }

  Widget _appBar() {
    return AppBar(
      title: Text('Review comments'),
      textTheme: Theme.of(context).textTheme,
      backgroundColor: Theme.of(context).backgroundColor,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildInput({required ReviewCommentsState state}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              color: Theme.of(context).cardColor,
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyText1,
                controller: textMessageController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your comment...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
                onTap: () {},
              ),
            ),
          ),
          Container(
            margin: new EdgeInsets.only(left: 8.0),
            child: new IconButton(
              icon: new Icon(
                Icons.send,
                color: Theme.of(context).buttonColor,
              ),
              onPressed: () => _sendComment(state: state),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
            top: new BorderSide(color: Color(0xFF3345A9), width: 0.5),
          ),
          color: Theme.of(context).cardColor),
    );
  }

  _buildTextMessage(String comment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      // constraints: BoxConstraints(
      //   maxWidth: MediaQuery.of(context).size.width - 96,
      // ),
      child: Text(
        comment,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  _scrollToBottom({bool isAnimate = false}) {
    final threshold = .5;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.hasClients == false) return;
      final offset = _scrollController.position.maxScrollExtent + threshold;
      if (isAnimate) {
        _scrollController.animateTo(
          offset,
          duration: Duration(seconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    });
  }

  Widget buildItem(
    int index,
    ReviewCommentWithUser item,
    User? user,
    String comment,
  ) {
    Widget messageWidget = _buildTextMessage(comment);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            right: 8,
            left: 16,
          ),
          child: UserAvatar(
            radius: 16,
            user: (user != null) ? user.id : item.userId,
            profile: (user != null) ? user.profile : null,
          ),
        ),
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  user?.profile?.name ?? '',
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    timeago.format(item.dateCreated!),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
            messageWidget,
          ],
        )),
      ],
    );
  }

  Widget _buildListComments(
    InReviewCommentsState state,
  ) {
    return AnimatedStreamList<ReviewCommentWithUser>(
      shrinkWrap: true,
      scrollController: _scrollController,
      streamList: state.commentsSubscription.comments(),
      padding: EdgeInsets.only(top: 32, bottom: 16),
      itemBuilder: (
        ReviewCommentWithUser item,
        int index,
        BuildContext context,
        Animation<double> animation,
      ) {
        final widget = buildItem(
          index,
          item,
          item.user,
          item.comment!,
        );

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          child: widget,
        );
      },
      itemRemovedBuilder: (
        ReviewCommentWithUser item,
        int index,
        BuildContext context,
        Animation<double> animation,
      ) =>
          SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: Text(item.comment!),
      ),
    );
  }

  Widget _buildTimelineReviewItem(TimelineReview review) {
    return ReviewTile(
      review: review,
      isFullStyle: false,
    )
      ..setCommentCallback(() {
        // navigateReviewComment(review);
      })
      ..setLikeCallback((value) {
        // widget._exploreBloc.toggleLikeReview(review.review.id);
      } as Future<bool?> Function(bool));
  }

  _buildReviewAndComments({required ReviewCommentsState state}) {
    if (state is InReviewCommentsState) {
      return ListView(children: [
        _buildTimelineReviewItem(this._review),
        _buildListComments(state),
      ]);
    }
    return Container();
  }

  Widget _body(ReviewCommentsState state) {
    return _buildReviewAndComments(state: state);
  }

  _sendComment({required ReviewCommentsState state}) {
    widget._reviewCommentsBloc.add(
      SendCommentEvent(
        reviewId: this._review.review!.id,
        text: this.textMessageController.text,
      ),
    );

    this.textMessageController.text = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(
        Duration(milliseconds: 1500),
        () => _scrollToBottom(),
      );
    });
  }

  void _load([bool isError = false]) {
    widget._reviewCommentsBloc
        .add(LoadReviewCommentsEvent(isError, _review.review!.id));
  }
}
