import 'package:flutter/material.dart';
import 'index.dart';
import '../view/screen_bar.dart';

import '../screen_arguments.dart';

class PhotoListPage extends StatelessWidget {
  static const String routeName = '/photoList';

  @override
  Widget build(BuildContext context) {
    final PhotoListPageArguments args =
        ModalRoute.of(context)!.settings.arguments as PhotoListPageArguments;
    return Scaffold(
      appBar: ScreenBar(Text('${args.photos!.length} photos',
          style: Theme.of(context).textTheme.headline2)),
      body: PhotoListScreen(),
    );
  }
}
