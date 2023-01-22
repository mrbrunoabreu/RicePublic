import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class MapMarker extends Clusterable {
  String? locationName;
  String? thumbnailSrc;
  VoidCallback? onTap;

  MapMarker(
      {required this.locationName,
      required latitude,
      required longitude,
      this.thumbnailSrc,
      isCluster = false,
      clusterId,
      pointsSize,
      MarkerId? markerId,
      childMarkerId,
      this.onTap})
      : super(
            latitude: latitude,
            longitude: longitude,
            isCluster: isCluster,
            clusterId: clusterId,
            pointsSize: pointsSize,
            markerId: markerId.toString(),
            childMarkerId: childMarkerId);
}
