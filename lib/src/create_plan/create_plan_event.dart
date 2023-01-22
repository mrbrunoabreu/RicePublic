import 'dart:async';
import 'dart:developer' as developer;

import 'package:rice/src/create_plan/index.dart';
import 'package:meta/meta.dart';
import 'package:rice/src/repository/model/plan.dart';
import 'package:rice/src/repository/model/restaurant.dart';
import 'package:rice/src/repository/model/user.dart';

@immutable
abstract class CreatePlanEvent {
  Future<CreatePlanState?> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc});
}

class OnCreatePlanEvent extends CreatePlanEvent {
  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    return InCreatePlanState(0);
  }
}

class LoadCreatePlanEvent extends CreatePlanEvent {
  final bool isError;
  @override
  String toString() => 'LoadCreatePlanEvent';

  LoadCreatePlanEvent(this.isError);

  @override
  Future<CreatePlanState?> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      if (currentState is InCreatePlanState) {
        return currentState.getNewVersion();
      }
      return currentState;
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'LoadCreatePlanEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }
}

class UploadPlanEvent extends CreatePlanEvent {
  final String note;
  final String? planId;

  @override
  String toString() => 'UploadPlanEvent';

  UploadPlanEvent({required this.note, required this.planId});

  @override
  Future<CreatePlanState?> applyAsync({
    CreatePlanState? currentState,
    CreatePlanBloc? bloc,
  }) async {
    if (currentState is InCreatePlanState) {
      try {
        final currentUser = await bloc!.findCurrentUser();
        List<User>? users;
        if (currentState.friends != null) {
          currentState.friends?.add(currentUser);
          users = currentState.friends;
        } else {
          users = [currentUser];
        }
        final plan = Plan(
          id: this.planId,
          userId: currentUser.id,
          restaurantId: currentState.restaurant!.id,
          restaurant: currentState.restaurant,
          dateCreated: DateTime.now(),
          isPublic: currentState.isPublic,
          isJoinable: currentState.planType == 'anyone',
          isFollowersOnly: currentState.planType == 'friends',
          planDate: currentState.day,
          users: users,
          additionalComments: note,
        );

        if (this.planId == null) {
          await bloc.createPlan(plan);
        } else {
          await bloc.updatePlan(plan);
        }

        return CreatedPlanState(1);
      } catch (error, stackTrace) {
        developer.log(
          '$error',
          name: 'UploadPlanEvent',
          error: error,
          stackTrace: stackTrace,
        );

        return ErrorCreatePlanState(
          1,
          errorMessage: error?.toString(),
        );
      }
    }
    return currentState;
  }
}

class OnRestaurantSelectEvent extends CreatePlanEvent {
  final Restaurant? restaurant;

  OnRestaurantSelectEvent(this.restaurant);

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      final newState = (currentState as InCreatePlanState).getNewVersionWith(
        restaurantId: this.restaurant?.id,
        restaurant: this.restaurant,
      );

      return newState;
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnRestaurantSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnRestaurantSelectEvent';
}

class OnDateSelectEvent extends CreatePlanEvent {
  final DateTime? day;

  OnDateSelectEvent(this.day);

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      return (currentState as InCreatePlanState).getNewVersionWith(
        day: day,
      );
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnDateSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnDateSelectEvent';
}

class OnTimeSelectEvent extends CreatePlanEvent {
  final DateTime time;

  OnTimeSelectEvent(this.time);

  @override
  Future<CreatePlanState?> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      if (currentState is InCreatePlanState) {
        if (currentState.day != null) {
          return currentState.getNewVersionWith(
            day: DateTime(
              currentState.day!.year,
              currentState.day!.month,
              currentState.day!.day,
              time.hour,
              time.minute,
            ),
          );
        }

        return currentState.getNewVersionWith(day: this.time);
      }

      return currentState as InCreatePlanState?;
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnTimeSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnTimeSelectEvent';
}

class OnIsPublicSelectEvent extends CreatePlanEvent {
  final bool? isPublic;

  OnIsPublicSelectEvent(this.isPublic);

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      return (currentState as InCreatePlanState)
          .getNewVersionWith(isPublic: isPublic);
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnIsPublicSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );
      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnIsPublicSelectEvent';
}

class OnPlanTypeSelectEvent extends CreatePlanEvent {
  final String? planType;

  OnPlanTypeSelectEvent(this.planType);

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      return (currentState as InCreatePlanState)
          .getNewVersionWith(planType: planType);
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnPlanTypeSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnPlanTypeSelectEvent';
}

class OnFriendsSelectEvent extends CreatePlanEvent {
  final List<User>? friends;

  OnFriendsSelectEvent(this.friends);

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      return (currentState as InCreatePlanState).getNewVersionWith(
        friends: friends,
      );
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnFriendsSelectEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnFriendsSelectEvent $friends';
}

class OnPlanCreateSuccessEvent extends CreatePlanEvent {
  OnPlanCreateSuccessEvent();

  @override
  Future<CreatePlanState> applyAsync(
      {CreatePlanState? currentState, CreatePlanBloc? bloc}) async {
    try {
      return (currentState as InCreatePlanState)
          .getNewVersionWith(isCreatePlanSuccess: false);
    } catch (error, stackTrace) {
      developer.log(
        '$error',
        name: 'OnPlanCreateSuccessEvent',
        error: error,
        stackTrace: stackTrace,
      );

      return ErrorCreatePlanState(
        1,
        errorMessage: error?.toString(),
      );
    }
  }

  @override
  String toString() => 'OnPlanCreateSuccessEvent';
}
