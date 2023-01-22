import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import '../repository/rice_meteor_service.dart';

abstract class ReviewCommentsState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  ReviewCommentsState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  ReviewCommentsState getStateCopy();

  ReviewCommentsState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

/// UnInitialized
class UnReviewCommentsState extends ReviewCommentsState with NeedShowLoader {
  UnReviewCommentsState(int version) : super(version);

  @override
  String toString() => 'UnReviewCommentsState';

  @override
  UnReviewCommentsState getStateCopy() {
    return UnReviewCommentsState(0);
  }

  @override
  UnReviewCommentsState getNewVersion() {
    return UnReviewCommentsState(version + 1);
  }
}

/// Initialized
class InReviewCommentsState extends ReviewCommentsState {
  final ReviewCommentsSubscription commentsSubscription;

  InReviewCommentsState(int version, this.commentsSubscription)
      : super(version, [commentsSubscription]);

  @override
  String toString() => 'InReviewCommentsState $commentsSubscription';

  @override
  InReviewCommentsState getStateCopy() {
    return InReviewCommentsState(this.version, this.commentsSubscription);
  }

  @override
  InReviewCommentsState getNewVersion() {
    return InReviewCommentsState(version + 1, this.commentsSubscription);
  }
}

class ErrorReviewCommentsState extends ReviewCommentsState {
  final String errorMessage;

  ErrorReviewCommentsState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorReviewCommentsState';

  @override
  ErrorReviewCommentsState getStateCopy() {
    return ErrorReviewCommentsState(this.version, this.errorMessage);
  }

  @override
  ErrorReviewCommentsState getNewVersion() {
    return ErrorReviewCommentsState(version + 1, this.errorMessage);
  }
}
