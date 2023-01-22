import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/post/index.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/screen_arguments.dart';

class PostPage extends StatelessWidget {
  static const String routeName = '/post';

  @override
  Widget build(BuildContext context) {
    final PostPageArguments args =
        ModalRoute.of(context)!.settings.arguments as PostPageArguments;
    var _postBloc = PostBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Post'),
      // ),
      // backgroundColor: Colors.white,
      body: PostScreen(postId: args.postId, postBloc: _postBloc),
    );
  }
}
