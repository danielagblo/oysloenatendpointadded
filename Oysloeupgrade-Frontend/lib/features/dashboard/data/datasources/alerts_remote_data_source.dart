import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/alert_model.dart';

abstract class AlertsRemoteDataSource {
  Future<List<AlertModel>> getAlerts();
  Future<void> markAlertRead(AlertModel alert);
  Future<void> deleteAlert(int id);
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  AlertsRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.alertsURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<List<AlertModel>> getAlerts() async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      if (response.data is List<dynamic>) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> raw) =>
                  AlertModel.fromJson(Map<String, dynamic>.from(raw)),
            )
            .toList();
      }
      if (response.data == null) {
        return <AlertModel>[];
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> markAlertRead(AlertModel alert) async {
    final String path = AppStrings.alertMarkReadURL(alert.id.toString());
    try {
      await _client.post<dynamic>(
        path,
        data: <String, dynamic>{
          'title': alert.title,
          'body': alert.body,
          'kind': alert.kind,
          'is_read': true,
        },
      );
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> deleteAlert(int id) async {
    final String path = AppStrings.alertDeleteURL(id.toString());
    try {
      await _client.delete<dynamic>(path);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
