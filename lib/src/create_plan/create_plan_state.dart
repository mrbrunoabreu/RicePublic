import 'package:equatable/equatable.dart';
import '../base_bloc.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:rice/src/repository/model/user.dart';

abstract class CreatePlanState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  CreatePlanState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  CreatePlanState getStateCopy();

  CreatePlanState getNewVersion();

  @override
  List<Object?> get props => propss!;
}

class InCreatePlanState extends CreatePlanState {
  final Restaurant? restaurant;
  final String? restaurantId;
  final DateTime? day;
  final bool? isPublic;
  final String? planType;
  final List<User>? friends;

  InCreatePlanState(
    int version, {
    this.restaurantId,
    this.restaurant,
    this.day,
    this.isPublic,
    this.planType,
    this.friends,
  }) : super(version, [
          version,
          restaurantId,
          restaurant,
          day,
          isPublic,
          planType,
          friends,
        ]);

  @override
  String toString() =>
      'InCreatePlanState $version $restaurantId, $restaurant, $day, $isPublic, $planType, $friends';

  @override
  InCreatePlanState getStateCopy() {
    return InCreatePlanState(
      this.version,
      restaurantId: this.restaurantId,
      restaurant: this.restaurant,
      day: this.day,
      isPublic: this.isPublic,
      planType: this.planType,
      friends: this.friends,
    );
  }

  @override
  InCreatePlanState getNewVersion() {
    return InCreatePlanState(
      version + 1,
      restaurantId: this.restaurantId,
      restaurant: this.restaurant,
      day: this.day,
      isPublic: this.isPublic,
      planType: this.planType,
      friends: this.friends,
    );
  }

  InCreatePlanState getNewVersionWith({
    String? restaurantId,
    Restaurant? restaurant,
    DateTime? day,
    bool? isPublic,
    String? planType,
    List<User>? friends,
    bool? isCreatePlanSuccess,
  }) {
    return InCreatePlanState(
      version + 1,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurant: restaurant ?? this.restaurant,
      day: day ?? this.day,
      isPublic: isPublic ?? this.isPublic,
      planType: planType ?? this.planType,
      friends: friends ?? this.friends,
    );
  }
}

class ErrorCreatePlanState extends CreatePlanState {
  final String? errorMessage;

  ErrorCreatePlanState(int version, {this.errorMessage}) : super(version);

  @override
  ErrorCreatePlanState getNewVersion() {
    return ErrorCreatePlanState(
      this.version + 1,
      errorMessage: this.errorMessage,
    );
  }

  @override
  ErrorCreatePlanState getStateCopy() {
    return ErrorCreatePlanState(
      this.version + 1,
      errorMessage: this.errorMessage,
    );
  }
}

class CreatedPlanState extends InCreatePlanState {
  CreatedPlanState(
    int version,
  ) : super(version);

  @override
  CreatedPlanState getNewVersion() {
    return CreatedPlanState(
      this.version + 1,
    );
  }

  @override
  CreatedPlanState getStateCopy() {
    return CreatedPlanState(
      this.version + 1,
    );
  }
}
