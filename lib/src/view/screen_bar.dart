import 'dart:ui';

import 'package:flutter/material.dart';

typedef LeftIconTapCallback = void Function();
typedef RightIconTapCallback = void Function();

class ScreenBar extends AppBar {
  final Widget? rightIcon;
  final RightIconTapCallback? rightIconTapCallback;
  final bool isBackIcon;
  ScreenBar(title,
      {
        this.rightIcon, 
        this.rightIconTapCallback, 
        this.isBackIcon = true, 
        bottom,
        Color? backgroundColor = null,
        Brightness? brightness = null,
      })
      : super(
          title: title, //Text('Results for ${args.arguments.name}'),
          iconTheme: IconThemeData(size: 28),
          bottom : bottom,
          elevation: 0,
          centerTitle: true,
          backgroundColor: backgroundColor,
          brightness: brightness,
          leading: Builder(
            builder: (BuildContext context) {
              
              return IconButton(
                icon: isBackIcon
                    ? const Icon(Icons.arrow_back_ios)
                    : const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              );
            },
          ),

          actions: (rightIcon != null)
              ? <Widget>[
                  IconButton(
                    // action button
                    icon: rightIcon,
                    onPressed: rightIconTapCallback,
                  )
                ]
              : null,
        );
}

double _straddleAppBar(ScaffoldPrelayoutGeometry scaffoldGeometry) {
  final double fabHalfHeight =
      scaffoldGeometry.floatingActionButtonSize.height / 2.0;
  return scaffoldGeometry.contentTop - fabHalfHeight;
}

double _centerOffset(ScaffoldPrelayoutGeometry scaffoldGeometry,
    {double offset = 0.0}) {
  return scaffoldGeometry.scaffoldSize.width / 2 -
      scaffoldGeometry.floatingActionButtonSize.width / 2 +
      offset;
}

double _startOffset(ScaffoldPrelayoutGeometry scaffoldGeometry,
    {double offset = 0.0}) {
  return _centerOffset(scaffoldGeometry, offset: offset);
}

class _CenterTopFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _CenterTopFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(
        _startOffset(scaffoldGeometry), _straddleAppBar(scaffoldGeometry));
  }

  @override
  String toString() => 'FloatingActionButtonLocation.centerTop';
}

const FloatingActionButtonLocation centerTopFloatingActionButtonLocation =
    _CenterTopFloatingActionButtonLocation();
