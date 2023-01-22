import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import '../signup/index.dart';
import '../base_bloc.dart';

class SignUpBloc extends BaseBloc<SignUpEvent, SignUpState> {
  SignUpBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnSignUpState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<bool> resetPassword(
      String? userId, String? token, String password) async {
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

  SignUpState get initialState => UnSignUpState(0);

  @override
  Future<void> mapEventToState(
    SignUpEvent event,
    Emitter<SignUpState> emitter,
  ) async {
    try {
      emitter(await (event.applyAsync(currentState: state, bloc: this)
          as FutureOr<SignUpState>));
    } catch (_, stackTrace) {
      developer.log('$_', name: 'SignUpBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
