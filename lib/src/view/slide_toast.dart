import 'package:flutter/material.dart';

class SlideToast extends StatefulWidget {
  final Widget _toast;

  SlideToast(this._toast);

  @override
  _SlideToastState createState() => _SlideToastState();
}

class _SlideToastState extends State<SlideToast> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetFloat;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetFloat = Tween(begin: Offset.zero, end: Offset(0.0, 20.0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _offsetFloat.addListener(() {
      setState(() {});
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetFloat,
      child: widget._toast,
    );
  }
}
