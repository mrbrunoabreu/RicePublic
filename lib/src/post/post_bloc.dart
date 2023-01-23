import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../repository/model/editorial.dart';
import '../repository/rice_repository.dart';

class PostBloc extends BaseBloc<PostEvent, PostState> {
  PostBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnPostState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<Post> getPost(String id) async {
    String fileText = await rootBundle.loadString('assets/html/blogpost.html');
    return Post(
        html: fileText,
        url: "https://minimalistbaker.com/easy-1-pan-salmon-red-curry/");
  }

  @override
  Future<void> mapEventToState(
    PostEvent event,
    Emitter<PostState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_', name: 'PostBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
