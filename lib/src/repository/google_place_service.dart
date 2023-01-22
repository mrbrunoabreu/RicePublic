import 'dart:developer' as developer;

import 'package:collection/collection.dart' show IterableNullableExtension;

import 'package:google_maps_webservice_ex/places.dart' as Places;
import 'package:google_maps_webservice_ex/geocoding.dart' as Geocoding;

// import 'package:google_maps_webservice/geocoding.dart' as Geocoding;
// import 'package:google_maps_webservice/places.dart' as Places;

import '../../environment_config.dart';
import 'model/restaurant.dart';

class GooglePlaceService {
  static const String API_KEY = EnvironmentConfig.google_map_api_key;
  // static final String _STATUS_OK = 'OK';

  static const String apiKey = EnvironmentConfig.google_map_api_key;
  final places = Places.GoogleMapsPlaces(apiKey: API_KEY);
  final geocoding = Geocoding.GoogleMapsGeocoding(apiKey: API_KEY);

  Future<List<Restaurant?>> searchNearbyWithRadius(double lat, double lng,
      {double radius = 700}) async {
    Places.PlacesSearchResponse response = await places.searchNearbyWithRadius(
        Places.Location(lat: lat, lng: lng), radius,
        type: 'restaurant');

    if (!response.isOkay) {
      // throw StateError(
      //     'searchNearbyWithRadius is not responded okay: ${response.errorMessage}');
      return [];
    }

    List<Future<Restaurant?>> futureRestaurants = response.results
        .map((r) async {
          Places.PlaceDetails details = await getPlaceDetails(r.placeId);
          if (details != null) {
            Restaurant restaurant = _toRestaurant(details);
            if (restaurant.photo == null && r.photos != null) {
              restaurant.photo = places.buildPhotoUrl(
                  photoReference: r.photos.first.photoReference,
                  maxHeight: 640,
                  maxWidth: 640);
            }
            return restaurant;
          }
          return null;
        })
        .whereNotNull()
        .toList();

    return Future.wait(futureRestaurants);
  }

  Future<Places.PlaceDetails> getPlaceDetails(String placeId) async {
    Places.PlacesDetailsResponse response =
        await places.getDetailsByPlaceId(placeId).catchError((error) {});

    if (!response.isOkay) {
      throw StateError('searchNearbyWithRadius is not responded okay');
    }

    developer.log(
      'Restaurant address: ${response.result!.formattedAddress}',
      name: 'getPlaceDetails',
    );
    return response.result!;
  }

  Future<List<String>> getPlacePhotoUrls(String placeId,
      {num? maxHeight, num? maxWidth}) async {
    Places.PlacesDetailsResponse response =
        await places.getDetailsByPlaceId(placeId).catchError((error) {});

    if (!response.isOkay) {
      throw StateError('searchNearbyWithRadius is not responded okay');
    }

    developer.log(
      'Restaurant address: ${response.result!.formattedAddress}',
      name: 'getPlacePhotoUrls',
    );
    return response.result!.photos.map((photo) {
      return places.buildPhotoUrl(
          photoReference: photo.photoReference,
          maxHeight:
              (maxHeight == null) ? photo.height as int? : maxHeight as int?,
          maxWidth:
              (maxWidth == null) ? photo.width as int? : maxWidth as int?);
    }).toList();
  }

  Future<List<Restaurant>> searchByKeyword(
    String keywords,
    double lat,
    double lng,
  ) async {
    Places.PlacesSearchResponse response = await places.searchByText(
      keywords,
      location: Places.Location(lat: lat, lng: lng),
      type: 'bar,cafe,restaurant',
    );

    if (!response.isOkay) {
      return [];
    }

    List<Future<Restaurant>> futureRestaurants =
        response.results.map((r) async {
      Places.PlaceDetails details =
          await getPlaceDetails(r.placeId).catchError((error) {});
      return _toRestaurant(details);
    }).toList();

    return Future.wait(futureRestaurants);
  }

  Restaurant _toRestaurant(Places.PlaceDetails result) {
    String photoUrl = places.buildPhotoUrl(
        photoReference: result.photos.first.photoReference,
        maxHeight: 640,
        maxWidth: 640);
    return Restaurant(
      id: result.id,
      googlePlaceId: result.placeId,
      name: result.name,
      address: result.formattedAddress,
      rating: result.rating,
      photo: photoUrl,
      location: Location(type: 'Point', coordinates: [
        result.geometry!.location.lng,
        result.geometry!.location.lat,
      ]),
      openingHoursDetail: OpeningHoursDetail(
          result.openingHours?.openNow,
          result.openingHours?.periods != null
              ? result.openingHours!.periods
                  .map((period) => OpeningHoursPeriod(
                      OpeningHoursPeriodDate(
                          period.open!.day, period.open!.time),
                      OpeningHoursPeriodDate(
                          period.close?.day, period.close?.time)))
                  .toList()
              : [],
          result.openingHours?.weekdayText),
      phone: result.formattedPhoneNumber,
    );
  }

  List<Restaurant> _toRestaurants(List<Places.PlaceDetails> results) {
    return results.map((result) => _toRestaurant(result)).toList();
  }

  Future<String?> fetchPlaceName(double lat, double lng) async {
    Geocoding.GeocodingResponse response = await geocoding
        .searchByLocation(Geocoding.Location(lat: lat, lng: lng));
    Geocoding.GeocodingResult result = response.results.first;

    if (result.addressComponents.length >= 3) {
      return '${result.addressComponents[result.addressComponents.length - 2].longName}, ${result.addressComponents[result.addressComponents.length - 3].longName}';
    }
    return result.formattedAddress;
  }
}
