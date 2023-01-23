import 'package:flutter/material.dart';
import '../repository/model/restaurant.dart';

Widget buildList(Restaurant restaurant, double size) {
  var rectSize = size - 10;
  return SizedBox(
      width: rectSize,
      child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  restaurant.photo != null
                      ? restaurant.photo!
                      : "https://via.placeholder.com/${rectSize.floor()}x${rectSize.floor()}",
                  height: rectSize,
                  width: rectSize,
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              restaurant.name!,
                              textAlign: TextAlign.justify,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              maxLines: 4,
                              style: TextStyle(
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.white),
                            )),
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        restaurant.address != null ? restaurant.address! : '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                          // color: Color.fromARGB(255, 170, 170, 170)),
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ],
          )));
}
