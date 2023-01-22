import 'dart:async';
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../onboarding/index.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;

@immutable
abstract class OnboardingEvent {
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc});
}

class UnOnboardingEvent extends OnboardingEvent {
  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    return UnOnboardingState();
  }
}

class RequestPasswordRecoveryEvent extends OnboardingEvent {
  final String email;

  RequestPasswordRecoveryEvent({required this.email});

  @override
  Future<OnboardingState> applyAsync({
    OnboardingState? currentState,
    OnboardingBloc? bloc,
  }) async {
    await bloc!.recoverPassword(email: this.email);

    return SentPasswordRecoveryState();
  }
}

class RegisterByEmailOnboardingEvent extends OnboardingEvent {
  final String name;
  final String email;

  RegisterByEmailOnboardingEvent({
    required this.name,
    required this.email,
  });

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    try {
      bool isSentEmail = await bloc!.register(name, email);
      return isSentEmail
          ? SentEnrollmentEmailOnboardingState()
          : ErrorOnboardingState('Unknown');
    } catch (error) {
      return ErrorOnboardingState(error.toString());
    }
  }
}

class SignUpByTokenOnboardingEvent extends OnboardingEvent {
  final String? userId;
  final String token;
  final String password;

  SignUpByTokenOnboardingEvent({
    required this.userId,
    required this.token,
    required this.password,
  });

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    try {
      bool isLoggedIn = await bloc!.resetPassword(userId, token, password);
      return isLoggedIn
          ? LoggedInOnboardingState()
          : ErrorOnboardingState('Unknown');
    } catch (error) {
      return ErrorOnboardingState(error.toString());
    }
  }
}

class LoginByEmailOnboardingEvent extends OnboardingEvent {
  final String email;
  final String password;

  LoginByEmailOnboardingEvent({
    required this.email,
    required this.password,
  });

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    try {
      bool isLoggedIn = await bloc!.login(email, password);

      return isLoggedIn
          ? LoggedInOnboardingState()
          : ErrorOnboardingState('Unknown');
    } catch (error) {
      developer.log('Wrong email or password');

      return ErrorOnboardingState('Wrong email or password');
    }
  }
}

class MissingInfomationOnboardingEvent extends OnboardingEvent {
  final String message;

  MissingInfomationOnboardingEvent({
    required this.message,
  });

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    return ErrorOnboardingState(message);
  }
}

class LoginByFacebookOnboardingEvent extends OnboardingEvent {
  final AccessToken? token;

  LoginByFacebookOnboardingEvent({
    required this.token,
  });

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    try {
      bool isLoggedIn = await bloc!.loginByFacebook(token!);

      return isLoggedIn
          ? LoggedInOnboardingState()
          : ErrorOnboardingState('Unknown');
    } catch (error) {
      try {
        final Map<String, dynamic> err = jsonDecode(error.toString());
        String errMsg = err['message'].toString();
        if (errMsg.contains('already exists')) {
          errMsg += '\nPlease login with the email.';
        }

        return ErrorOnboardingState(errMsg);
      } catch (e) {
        return ErrorOnboardingState(error.toString());
      }
    }
  }
}

class SigningUpOnboardingEvent extends OnboardingEvent {
  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    return SingingUpState();
  }
}

class LoadOnboardingEvent extends OnboardingEvent {
  @override
  String toString() => 'LoadOnboardingEvent';

  @override
  Future<OnboardingState> applyAsync(
      {OnboardingState? currentState, OnboardingBloc? bloc}) async {
    try {
      developer.log('Load onboard event $currentState');

      if (currentState is InOnboardingState) {
        return currentState.getStateCopy();
      }

      final isLoggedIn = await bloc!.isLoggedIn();

      developer.log('Login event result: $isLoggedIn');

      if (isLoggedIn) {
        if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
          FirebaseCrashlytics.instance
              .setUserIdentifier(bloc.getCurrentUserId()!);
        }
        return LoggedInOnboardingState();
      }

      return InOnboardingState();
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadOnboardingEvent', error: _, stackTrace: stackTrace);
      return ErrorOnboardingState(_?.toString());
    }
  }
}
