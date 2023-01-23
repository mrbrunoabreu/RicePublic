import 'package:flutter/material.dart';
import '../review_list/index.dart';
import '../view/screen_bar.dart';

import '../screen_arguments.dart';

class ReviewListPage extends StatelessWidget {
  static const String routeName = '/reviewList';

  @override
  Widget build(BuildContext context) {
    final ReviewListPageArguments args =
        ModalRoute.of(context)!.settings.arguments as ReviewListPageArguments;
    return Scaffold(
      appBar: ScreenBar(
        Text('All ${args.reviews.length} Reviews',
            style: Theme.of(context).textTheme.headline2),
        isBackIcon: true,
      ),
      body: Container(
          color: Theme.of(context).backgroundColor, child: ReviewListScreen()),
    );
  }
}
