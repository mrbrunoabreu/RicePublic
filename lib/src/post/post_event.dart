import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:rice/src/post/index.dart';
import 'package:meta/meta.dart';
import 'package:rice/src/utils.dart';

@immutable
abstract class PostEvent {
  Future<Position> loadUserLocation() async {
    return await loadUserLastLocation();
  }

  Future<PostState> applyAsync(
      {PostState? currentState, PostBloc? bloc});
  // final PostRepository _postRepository = PostRepository();
}

class UnPostEvent extends PostEvent {
  @override
  Future<PostState> applyAsync(
      {PostState? currentState, PostBloc? bloc}) async {
    return UnPostState(0);
  }
}

class LoadPostEvent extends PostEvent {
  final bool isError;
  final String id;
  @override
  String toString() => 'LoadPostEvent';

  LoadPostEvent(this.isError, this.id);

  @override
  Future<PostState> applyAsync(
      {PostState? currentState, PostBloc? bloc}) async {
    try {
      if (currentState is InPostState) {
        return currentState.getNewVersion();
      }

      var post = await bloc!.getPost(id);

      return InPostState(0, post);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadPostEvent', error: _, stackTrace: stackTrace);
      return ErrorPostState(0, _.toString());
    }
  }
}
