import 'package:equatable/equatable.dart';

abstract class MainState extends Equatable {
  /// notify change state without deep clone state
  final int version;
  
  final List? propss;
  MainState(this.version,[this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  MainState getStateCopy();

  MainState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnMainState extends MainState {

  UnMainState(int version) : super(version);

  @override
  String toString() => 'UnMainState';

  @override
  UnMainState getStateCopy() {
    return UnMainState(0);
  }

  @override
  UnMainState getNewVersion() {
    return UnMainState(version+1);
  }
}

/// Initialized
class InMainState extends MainState {
  final String hello;

  InMainState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InMainState $hello';

  @override
  InMainState getStateCopy() {
    return InMainState(this.version, this.hello);
  }

  @override
  InMainState getNewVersion() {
    return InMainState(version+1, this.hello);
  }
}

class ErrorMainState extends MainState {
  final String errorMessage;

  ErrorMainState(int version, this.errorMessage): super(version, [errorMessage]);
  
  @override
  String toString() => 'ErrorMainState';

  @override
  ErrorMainState getStateCopy() {
    return ErrorMainState(this.version, this.errorMessage);
  }

  @override
  ErrorMainState getNewVersion() {
    return ErrorMainState(version+1, this.errorMessage);
  }
}
