import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:deliverzler/core/errors/failures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:deliverzler/core/services/apis_services/apis_caller.dart';
import 'package:deliverzler/core/services/apis_services/apis_paths.dart';
import 'package:deliverzler/modules/map/models/place_directions_model.dart';
import 'package:deliverzler/modules/map/utils/constants.dart';
import 'package:deliverzler/modules/map/models/place_search_model.dart';
import 'package:deliverzler/modules/map/models/place_details_model.dart';

class MapRepo {
  MapRepo._();

  static final MapRepo instance = MapRepo._();

  final ApisCaller _apiCaller = ApisCaller.instance;

  Future<Either<Failure?, List<PlaceSearchModel>>> getPlaceSearchSuggestions({
    required String placeName,
    required String sessionToken,
  }) async {
    return await _apiCaller.getData(
      path: ApisPaths.googleMapAutoCompletePath(),
      queryParameters: {
        'input': placeName,
        'types': '(cities)',
        'components': 'country:eg',
        'key': googleMapAPIKey,
        'sessiontoken': sessionToken,
      },
      builder: (data) {
        if (data != null && data is! ServerFailure) {
          if (data['status'] == 'OK') {
            return Right(List<PlaceSearchModel>.from(
              data['predictions'].map(
                (e) => PlaceSearchModel.fromMap(e),
              ),
            ));
          } else {
            return const Right([]);
          }
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure?, PlaceDetailsModel>> getPlaceDetails({
    required String placeId,
    required String sessionToken,
  }) async {
    return await _apiCaller.getData(
      path: ApisPaths.googleMapPlaceDetailsPath(),
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry', //Specify wanted fields to lower billing rate
        'key': googleMapAPIKey,
        'sessiontoken': sessionToken,
      },
      builder: (data) {
        if (data != null && data is! ServerFailure && data['status'] == 'OK') {
          return Right(PlaceDetailsModel.fromMap(data['result']));
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure?, PlaceDirectionsModel>> getPlaceDirections({
    required Position origin,
    required GeoPoint destination,
  }) async {
    return await _apiCaller.getData(
      path: ApisPaths.googleMapDirectionsPath(),
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleMapAPIKey,
      },
      builder: (data) {
        if (data != null && data is! ServerFailure && data['status'] == 'OK') {
          return Right(PlaceDirectionsModel.fromMap(data));
        } else {
          return Left(data);
        }
      },
    );
  }
}
