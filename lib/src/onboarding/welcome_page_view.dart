import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class Item {
  String title;
  String description;
  String imagePath;
  Item(@required this.title, @required this.description,
      @required this.imagePath);
}

class WelcomePageView extends StatelessWidget {
  static const String routeName = "/welcomePageView";

  final _items = [
    Item(
        "Welcome\nto Rice",
        "Follow friends, meet people and find new places to eat",
        "assets/images/bg_welcome_1.png"),
    Item(
        "Places to eat",
        "Rate and follow your favourite & explore new places. ",
        "assets/images/bg_welcome_2.png"),
    Item(
        "People to meet",
        "Follow friends, meet new people and make plans together",
        "assets/images/bg_welcome_3.png"),
  ];
  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);

  Widget _buildPage({int? index, required Item item}) {
    return Container(
        alignment: AlignmentDirectional.topStart,
        // color: Colors.black,
        decoration: new BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage(item.imagePath),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
                  child: Text(
                    '${item.title}',
                    style: TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
                  child: Text(
                    '${item.description}',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: CirclePageIndicator(
                  dotColor: Colors.white,
                  selectedDotColor: Colors.green,
                  itemCount: _items.length,
                  currentPageNotifier: _currentPageNotifier,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildPageView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PageView.builder(
      itemCount: _items.length,
      controller: _pageController,
      itemBuilder: (BuildContext context, int index) {
        return
            // Stack(
            //   children: [
            // Center(
            //   child: Image.asset(
            //     _items[index].imagePath,
            //     width: size.width,
            //     height: size.height,
            //     fit: BoxFit.fill,
            //   ),
            // ),
            _buildPage(index: index, item: _items[index])
            //   ],
            // )
            ;
      },
      onPageChanged: (int index) {
        _currentPageNotifier.value = index;
      },
    );
  }

  _buildCircleIndicator() {
    return Positioned(
      left: 24.0,
      top: 288.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CirclePageIndicator(
          dotColor: Colors.white,
          selectedDotColor: Colors.green,
          itemCount: _items.length,
          currentPageNotifier: _currentPageNotifier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildPageView(context),
          // _buildCircleIndicator(),
        ],
      ),
    );
  }
}
