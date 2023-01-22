// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) {
  return Restaurant(
    googlePlaceId: json['googlePlaceId'] as String?,
    name: json['name'] as String?,
    address: json['address'] as String?,
    photo: json['photo'] as String?,
    location: json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    rating: json['overallRating'] as num?,
    openingHoursDetail: json['openingHoursDetail'] == null
        ? null
        : OpeningHoursDetail.fromJson(
            json['openingHoursDetail'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) {
  final val = <String, dynamic>{
    'googlePlaceId': instance.googlePlaceId,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address);
  writeNotNull('photo', instance.photo);
  writeNotNull('overallRating', instance.rating);
  val['location'] = instance.location;
  val['openingHoursDetail'] = instance.openingHoursDetail;
  return val;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    type: json['type'] as String?,
    coordinates: (json['coordinates'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList(),
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) {
  return OpeningHours(
    json['openNow'] as bool?,
  );
}

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'openNow': instance.openNow,
    };

OpeningHoursDetail _$OpeningHoursDetailFromJson(Map<String, dynamic> json) {
  return OpeningHoursDetail(
    json['openNow'],
    (json['periods'] as List?)
        ?.map((e) => 
            OpeningHoursPeriod.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['weekdayText'] as List?)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$OpeningHoursDetailToJson(OpeningHoursDetail instance) =>
    <String, dynamic>{
      'openNow': instance.openNow,
      'periods': instance.periods,
      'weekdayText': instance.weekdayText,
    };

OpeningHoursPeriodDate _$OpeningHoursPeriodDateFromJson(
    Map<String, dynamic> json) {
  return OpeningHoursPeriodDate(
    json['day'] as int?,
    json['time'] as String?,
  );
}

Map<String, dynamic> _$OpeningHoursPeriodDateToJson(
        OpeningHoursPeriodDate instance) =>
    <String, dynamic>{
      'day': instance.day,
      'time': instance.time,
    };

OpeningHoursPeriod _$OpeningHoursPeriodFromJson(Map<String, dynamic> json) {
  return OpeningHoursPeriod(
    json['open'] == null
        ? null
        : OpeningHoursPeriodDate.fromJson(json['open'] as Map<String, dynamic>),
    json['close'] == null
        ? null
        : OpeningHoursPeriodDate.fromJson(
            json['close'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$OpeningHoursPeriodToJson(OpeningHoursPeriod instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
    };

AwardDetail _$AwardDetailFromJson(Map<String, dynamic> json) {
  return AwardDetail(
    json['icon'] as String?,
    json['globalTitle'] as String?,
    json['regionTitle'] as String?,
  );
}

Map<String, dynamic> _$AwardDetailToJson(AwardDetail instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'globalTitle': instance.globalTitle,
      'regionTitle': instance.regionTitle,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$RestaurantToString(Restaurant o) {
  return """Restaurant{id: ${o.id}, googlePlaceId: ${o.googlePlaceId}, name: ${o.name}, address: ${o.address}, photo: ${o.photo}, rating: ${o.rating}, location: ${o.location}, openingHoursDetail: ${o.openingHoursDetail}, phone: ${o.phone}, awardDetail: ${o.awardDetail}}""";
}
