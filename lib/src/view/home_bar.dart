import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';

typedef LeftIconTapCallback = void Function();
typedef RightIconTapCallback = void Function();

class HomeBar extends StatefulWidget {
  final LeftIconTapCallback? leftIconTapCallback;
  final RightIconTapCallback? rightIconTapCallback;

  HomeBar({this.leftIconTapCallback, this.rightIconTapCallback});

  @override
  State<StatefulWidget> createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    // return PreferredSize(
    //   preferredSize: Size.fromHeight(100)
    //   );
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.white10, spreadRadius: 0, blurRadius: 0)
        ]),
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          // borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(15),
          //     bottomRight: Radius.circular(15)),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: SafeArea(
                child: Container(
              height: 56,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: widget.leftIconTapCallback,
                            child: Icon(Ionicons.notifications_outline)
                            
                            // SvgPicture.asset(
                            //   'assets/icon/ic_bell.svg',
                            //   width: 24,
                            //   height: 24,
                            // )
                            
                            )
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          isDarkMode ?
                          'assets/images/rice_bar_logo_dark.png' : 'assets/images/rice_bar_logo.png',
                          width: 50,
                          height: 50,
                        )
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: widget.rightIconTapCallback,
                            child: Icon(Ionicons.search_outline)
                            
                            // SvgPicture.asset(
                            //   'assets/icon/ic_search.svg',
                            //   width: 24,
                            //   height: 24,
                            // )
                            )
                      ]),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class PageBar extends StatefulWidget {
  final LeftIconTapCallback? leftIconTapCallback;
  final RightIconTapCallback? rightIconTapCallback;
  final Widget? rightIcon;
  final String title;

  PageBar(
      {required this.title,
      this.leftIconTapCallback,
      this.rightIconTapCallback,
      this.rightIcon});

  @override
  State<StatefulWidget> createState() => _PageBarState();
}

class _PageBarState extends State<PageBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.white10, spreadRadius: 0, blurRadius: 0)
        ]),
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: SafeArea(
                child: Container(
              height: 56,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: widget.leftIconTapCallback,
                            child: Icon(Ionicons.notifications_outline)
                            
                            // SvgPicture.asset(
                            //   'assets/icon/ic_bell.svg',
                            //   width: 24,
                            //   height: 24,
                            // )
                            )
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              widget.title.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: widget.rightIconTapCallback,
                            child: widget.rightIcon)
                      ]),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
