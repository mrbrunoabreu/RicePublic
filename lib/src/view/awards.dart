import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Awards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Awards', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/icon/michelinStar.svg',
                    width: 13, height: 15),
                SvgPicture.asset('assets/icon/michelinStar.svg',
                    width: 13, height: 15),
                SvgPicture.asset('assets/icon/michelinStar.svg',
                    width: 13, height: 15),
                VerticalDivider(color: Theme.of(context).hintColor, width: 3),
                Text('World\'s 50 Best',
                    style: Theme.of(context).textTheme.headline6),
                VerticalDivider(color: Theme.of(context).hintColor, width: 3),
                Text('OAD Top 100',
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
