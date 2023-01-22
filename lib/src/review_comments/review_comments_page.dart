import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/review_comments/index.dart';
import 'package:rice/src/screen_arguments.dart';

class ReviewCommentsPage extends StatelessWidget {
  static const String routeName = '/reviewComments';

  @override
  Widget build(BuildContext context) {
    final ReviewCommentsPageArguments args = ModalRoute.of(context)!
        .settings
        .arguments as ReviewCommentsPageArguments;
    var _reviewCommentsBloc =
        ReviewCommentsBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('ReviewComments'),
      // ),
      // backgroundColor: Colors.white,
      body: ReviewCommentsScreen(
          review: args.review, reviewCommentsBloc: _reviewCommentsBloc),
    );
  }
}
