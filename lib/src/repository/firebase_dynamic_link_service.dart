import 'dart:async';
import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../onboarding/index.dart';
import '../repository/navigation_service.dart';
import '../reset_password/index.dart';
import '../screen_arguments.dart';
import '../signup/index.dart';

class DynamicLinkService {
  static final String TAG = "DynamicLinkService";

  static DynamicLinkService _instance = DynamicLinkService._internal();
  factory DynamicLinkService() => _instance;
  DynamicLinkService._internal();

  Future handleDynamicLinks(BuildContext context) async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(context, data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(context, dynamicLink);
    }).onError((e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(BuildContext context, PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      _retrieveArgumentsAndNavigate(context, deepLink);
      print('_handleDeepLink | deeplink: $deepLink');
    }
  }

  dynamic _retrieveArgumentsAndNavigate(BuildContext context, Uri deepLink) {
    var path = deepLink.path;
    dynamic args = null;
    switch (path) {
      case ResetPasswordPage.routeName:
        {
          String? token = deepLink.queryParameters['reset-pwd-token'];
          args = ResetPasswordPageArguments(token: token);
          NavigationService().navigateToWithContext(context, path, args);
        }
        break;
      case OnboardingPage.routeName:
        {
          String token = deepLink.queryParameters['enroll-token']!;
          String decoded = utf8.decode(base64.decode(token));
          Uri tokenUri = Uri.parse("localhost?$decoded");
          String? signUpToken = tokenUri.queryParameters['token'];
          String userId = tokenUri.queryParameters['id']!;
          userId = userId.replaceAll(RegExp(' '), '+');
          args =
              SignUpPageArguments(signUpToken: signUpToken, userEmail: userId);
          NavigationService()
              .navigateToWithContext(context, SignUpPage.routeName, args);
        }
        break;
    }
    return args;
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        dynamic args = _retrieveArgumentsAndNavigate(context, deepLink);
        NavigationService().navigateToWithContext(context, deepLink.path, args);
      }

      FirebaseDynamicLinks.instance.onLink
          .listen((PendingDynamicLinkData dynamicLink) async {
        // 3a. handle link that has been retrieved
        _handleDeepLink(context, dynamicLink);
      }).onError((e) async {
        print('Link Failed: ${e.message}');
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
