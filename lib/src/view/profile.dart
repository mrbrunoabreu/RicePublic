import 'package:flutter/material.dart';

import 'gallery_photo_view.dart';

class ProfileGalleryRow extends StatelessWidget {
  // final Restaurant restaurant;
  VoidCallback? tappedCallback = () {};

  List<GalleryItem> _galleryItems = [];

  static const int photoCount = 432;

  ProfileGalleryRow({this.tappedCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Text(
                                'My photos',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ))),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                                onTap: tappedCallback,
                                child: Text(
                                  'See all >',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Color.fromARGB(255, 51, 69, 169)),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                                onTap: () => open(context, 0, _galleryItems),
                                child: ClipRRect(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                    child: Image.network(
                                      "https://via.placeholder.com/96x96",
                                      fit: BoxFit.fill,
                                    ))))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                                onTap: () => open(context, 0, _galleryItems),
                                child: ClipRRect(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                    child: Image.network(
                                      "https://via.placeholder.com/96x96",
                                      fit: BoxFit.fill,
                                    ))))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                                onTap: () => open(context, 0, _galleryItems),
                                child: ClipRRect(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                    child: Image.network(
                                      "https://via.placeholder.com/96x96",
                                      fit: BoxFit.fill,
                                    ))))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                                onTap: () => open(context, 0, _galleryItems),
                                child: ClipRRect(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                    child: Image.network(
                                      "https://via.placeholder.com/96x96",
                                      fit: BoxFit.fill,
                                    ))))),
                  ],
                )
              ],
            )));
  }
}

// class FaviRestaurantRow extends StatelessWidget {
//   final Restaurant restaurant;
//   // final double height;
//   // final double width;
//   RestaurantRow(this.restaurant);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//         child: Container(
//             margin: EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                     child: Text(
//                       restaurant.name,
//                       softWrap: false,
//                       overflow: TextOverflow.fade,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     )),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Expanded(
//                           child: Padding(
//                               padding: EdgeInsets.only(right: 8),
//                               child: Text(
//                                 restaurant.address,
//                                 softWrap: false,
//                                 overflow: TextOverflow.fade,
//                                 style: TextStyle(
//                                   color: Color(0xFFAAAAAA),
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 12,
//                                 ),
//                               ))),
//                       Container(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(
//                               Icons.star,
//                               color: Color(0xFFF7C669),
//                               size: 12,
//                             ),
//                             Text('4.12',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ))
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     Expanded(
//                         flex: 1,
//                         child: Padding(
//                             padding: const EdgeInsets.all(4),
//                             child: ClipRRect(
//                                 borderRadius: new BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   "https://via.placeholder.com/96x96",
//                                   fit: BoxFit.fill,
//                                 )))),
//                     Expanded(
//                         flex: 1,
//                         child: Padding(
//                             padding: const EdgeInsets.all(4),
//                             child: ClipRRect(
//                                 borderRadius: new BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   "https://via.placeholder.com/96x96",
//                                   fit: BoxFit.fill,
//                                 )))),
//                     Expanded(
//                         flex: 1,
//                         child: Padding(
//                             padding: const EdgeInsets.all(4),
//                             child: ClipRRect(
//                                 borderRadius: new BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   "https://via.placeholder.com/96x96",
//                                   fit: BoxFit.fill,
//                                 )))),
//                     Expanded(
//                         flex: 1,
//                         child: Padding(
//                             padding: const EdgeInsets.all(4),
//                             child: ClipRRect(
//                                 borderRadius: new BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   "https://via.placeholder.com/96x96",
//                                   fit: BoxFit.fill,
//                                 )))),
//                   ],
//                 )
//               ],
//             )));
//   }
// }
