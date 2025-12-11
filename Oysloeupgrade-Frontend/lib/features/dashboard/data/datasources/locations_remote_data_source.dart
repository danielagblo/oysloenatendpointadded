import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/location_model.dart';

abstract class LocationsRemoteDataSource {
  Future<List<LocationModel>> getLocations();
  Future<List<LocationModel>> getLocationsByRegion(String region);
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  LocationsRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.locationsURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<LocationModel>> getLocations() async {
    try {
      print('Fetching locations from: $endpoint');
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      final dynamic data = response.data;

      print('Locations response status: ${response.statusCode}');
      print('Locations response data type: ${data.runtimeType}');
      print('Locations response data: $data');

      if (data is List<dynamic>) {
        print('Processing ${data.length} locations');
        final locations = data.whereType<Map<String, dynamic>>().map(
          (Map<String, dynamic> item) {
            print('Location item: $item');
            return LocationModel.fromJson(Map<String, dynamic>.from(item));
          },
        ).toList();
        print('Parsed ${locations.length} locations');
        return locations;
      }

      if (data == null) {
        print('Locations data is null, returning empty list');
        return const <LocationModel>[];
      }

      print('Unexpected response structure: $data');
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      print('Locations DioException: ${error.message}');
      print('Error response: ${error.response?.data}');
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      print('Locations error: $error');
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<LocationModel>> getLocationsByRegion(String region) async {
    try {
      print('Fetching locations for region: $region');
      final Response<dynamic> response = await _client.get<dynamic>(
        endpoint,
        queryParameters: {'region': region},
      );
      final dynamic data = response.data;

      print('Locations by region response status: ${response.statusCode}');
      print('Locations by region data: $data');

      if (data is List<dynamic>) {
        final locations = data.whereType<Map<String, dynamic>>().map(
          (Map<String, dynamic> item) {
            return LocationModel.fromJson(Map<String, dynamic>.from(item));
          },
        ).toList();
        print('Parsed ${locations.length} locations for region: $region');
        return locations;
      }

      if (data == null) {
        print('No locations found for region: $region');
        return const <LocationModel>[];
      }

      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      print('Locations by region DioException: ${error.message}');
      print('Error response: ${error.response?.data}');
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      print('Locations by region error: $error');
      throw ServerException(error.toString());
    }
  }
}
