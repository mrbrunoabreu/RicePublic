import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/model/profile.dart';
import 'package:tuple/tuple.dart';

abstract class FollowListState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  FollowListState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  FollowListState getStateCopy();

  FollowListState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

class UnFollowListState extends FollowListState with NeedShowLoader {
  UnFollowListState(int version) : super(version);

  @override
  String toString() => 'UnFollowListState';

  @override
  UnFollowListState getStateCopy() {
    return UnFollowListState(0);
  }

  @override
  UnFollowListState getNewVersion() {
    return UnFollowListState(version + 1);
  }
}

class InFollowListState extends FollowListState {
  final List<Tuple2<String, Profile>>? userList;

  InFollowListState(
    int version, {
    this.userList,
  }) : super(version, [userList]);

  @override
  String toString() => 'InFollowListState';

  @override
  InFollowListState getStateCopy() {
    return InFollowListState(0);
  }

  @override
  InFollowListState getNewVersion() {
    return InFollowListState(version + 1);
  }
}

class ErrorFollowListState extends FollowListState {
  final String errorMessage;

  ErrorFollowListState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorFollowListState';

  @override
  ErrorFollowListState getStateCopy() {
    return ErrorFollowListState(this.version, this.errorMessage);
  }

  @override
  ErrorFollowListState getNewVersion() {
    return ErrorFollowListState(version + 1, this.errorMessage);
  }
}
