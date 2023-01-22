import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/editorial.dart';

abstract class PostState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  PostState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  PostState getStateCopy();

  PostState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnPostState extends PostState with NeedShowLoader {
  UnPostState(int version) : super(version);

  @override
  String toString() => 'UnPostState';

  @override
  UnPostState getStateCopy() {
    return UnPostState(0);
  }

  @override
  UnPostState getNewVersion() {
    return UnPostState(version + 1);
  }
}

/// Initialized
class InPostState extends PostState {
  final Post post;

  InPostState(int version, this.post) : super(version, [post]);

  @override
  String toString() => 'InPostState $post';

  @override
  InPostState getStateCopy() {
    return InPostState(this.version, this.post);
  }

  @override
  InPostState getNewVersion() {
    return InPostState(version + 1, this.post);
  }
}

class ErrorPostState extends PostState {
  final String errorMessage;

  ErrorPostState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorPostState';

  @override
  ErrorPostState getStateCopy() {
    return ErrorPostState(this.version, this.errorMessage);
  }

  @override
  ErrorPostState getNewVersion() {
    return ErrorPostState(version + 1, this.errorMessage);
  }
}
