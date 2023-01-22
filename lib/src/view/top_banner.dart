import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rice/src/repository/model/editorial.dart';
import '../utils.dart';

class TopBanner extends StatefulWidget {
  final List<CarouselBanner> children;
  final double height;
  final double? horizontalPadding;
  final double elevation;
  final Function(String? id)? onTap;

  TopBanner({this.children = const <CarouselBanner>[], this.height = 300, this.onTap, this.horizontalPadding, this.elevation = 0});

  @override
  _TopBannerState createState() => _TopBannerState();
}

class _TopBannerState extends State<TopBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          widget.children != null && widget.children.length > 0
              ? _carouselSlider()
              : SizedBox(),

          Positioned(
              bottom: 0.0,
              left:   0.0,
              right:  0.0,
              child: _dots()
          )
        ]
    );
  }

  //region Widgets
  /// Carousel
  Widget _carouselSlider(){
    final CarouselController _controller = CarouselController();
    double fullWidth = MediaQuery.of(context).size.width;
    double viewportFraction = (fullWidth - widget.horizontalPadding!*2)/fullWidth;
    return CarouselSlider(
      items: widget.children.map((item) => _carouselItem(item)).toList(),
      options: CarouselOptions(height: widget.height,
      viewportFraction: viewportFraction,
      aspectRatio: 16 / 10,
      // onPageChanged: (index) => setState(() => _current = index);
      ),
      carouselController: _controller,
      // onPageChanged: (index) => setState(() => _current = index )
    );
  }

  /// Carousel items
  Widget _carouselItem(CarouselBanner carouselBanner){
    return GestureDetector(
      onTap: () => widget.onTap!(carouselBanner.id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0.0, 16, 0.0, 24.0),
        margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding!),
        child: Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          elevation: widget.elevation,
          child:ClipRRect(
            borderRadius: new BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _image(),
//                _text()
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Carousel indicators
  Widget _dots(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: mapIndexed(widget.children, (index, dynamic vaue) {
        return Container(
          width: 6.0,
          height: 6.0,
          margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? Color(0xFF3345A9)
                  : Color(0XFFD8D8D8)
          ),
        );
      }).toList(),
    );
  }

  /// Background image
  Widget _image(){
    return Container(
      child: Image.asset(
        "assets/images/bg_welcome_2.png",
        fit: BoxFit.fitWidth,
      ),
    );
  }

  /// Foreground text
  Widget _text(String title, String author){
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white),),
              SizedBox(height: 16),
              Text("By $author",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),),
            ],
          ),
        ));
  }
  //endregion
}
