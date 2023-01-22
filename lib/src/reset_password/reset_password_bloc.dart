import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import '../reset_password/index.dart';
import '../base_bloc.dart';

class ResetPasswordBloc
    extends BaseBloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnResetPasswordState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<void> resetPassword(String? token, String password) async {
    return riceRepository.resetPassword(token: token, newPassword: password);
  }

  @override
  Future<void> mapEventToState(
    ResetPasswordEvent event,
    Emitter<ResetPasswordState> emitter,
  ) async {
    try {
      emitter(await (event.applyAsync(currentState: state, bloc: this)
          as FutureOr<ResetPasswordState>));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ResetPasswordBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
