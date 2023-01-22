import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../base_bloc.dart';
import '../onboarding/index.dart';
import '../repository/facebook_service.dart';
import 'dart:developer' as developer;

import '../repository/rice_repository.dart';

class OnboardingBloc extends BaseBloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository, initialState: UnOnboardingState());

  FacebookService _facebookService = FacebookService();

  Future<void> recoverPassword({required String email}) {
    return this.riceRepository.recoverPassword(email: email);
  }

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<bool> register(String name, String email) async {
    String userId = await riceRepository.register(name, email);

    // return login(email, password).then((value) async {
    //   await riceRepository
    //       .updateProfile(Profile(name: name, picture: ProfilePic(url: "-")));
    //   return true;
    // });

    return true;
  }

  Future<bool> resetPassword(
      String? userId, String token, String password) async {
    await riceRepository.resetPassword(
        token: token, newPassword: password, onError: (e, _) => true);
    return login(userId, password).then((value) async {
      return true;
    });
  }

  Future<bool> login(String? email, String password) async {
    return riceRepository.login(email, password).then((loginToken) async {
      return await storeLoginToken(loginToken: loginToken);
    });
  }

  Future<bool> loginByFacebook(AccessToken accessToken) async {
    final FacebookCredential credential = FacebookCredential(
        id: accessToken.userId,
        accessToken: accessToken.token,
        expiresAt: accessToken.expires.millisecondsSinceEpoch.toString());
    final FacebookUserProfile profile =
        await _facebookService.getUserProfile(credential);

    final FacebookMeta meta = FacebookMeta(
        id: credential.id,
        accessToken: credential.accessToken,
        expiresAt: credential.expiresAt,
        email: profile.email,
        name: profile.name,
        first_name: profile.first_name,
        last_name: profile.last_name);
    return riceRepository.loginWithFacebook(meta).then((loginToken) async {
      return await storeLoginToken(loginToken: loginToken);
    });
  }

  @override
  Future<void> mapEventToState(
    OnboardingEvent event,
    Emitter<OnboardingState> emitter,
  ) async {
    try {
      emitter(LoadingOnboardingState());
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'OnboardingBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
