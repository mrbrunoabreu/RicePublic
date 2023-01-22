import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../onboarding/index.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';

class OnboardingPage extends StatelessWidget {
  static const String routeName = "/onboarding";

  @override
  Widget build(BuildContext context) {
    OnBoardingPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as OnBoardingPageArguments?;
    if (args != null && args.isLoggedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateOnboarding(context);
      });
      return Scaffold();
    }

    return Scaffold(
      body: OnboardingScreen(
        onboardingBloc:
            OnboardingBloc(riceRepository: context.read<RiceRepository>()),
        isSignUp: args == null ? false : args.isSignUp,
        signUpToken: args == null ? null : args.signUpToken,
        userId: args == null ? null : args.userId,
      ),
    );
  }

  _navigateOnboarding(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        OnboardingPage.routeName,
        ModalRoute.withName('/'),
      );
    });
  }
}
