import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/referral_model.dart';

abstract class ReferralRemoteDataSource {
  Future<ReferralModel> getReferralInfo();
  Future<List<PointsTransactionModel>> getReferralTransactions();
  Future<void> redeemCoupon(String code);
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  ReferralRemoteDataSourceImpl({
    required Dio client,
    this.endpoint = AppStrings.referralURL,
  }) : _client = client;

  final Dio _client;
  final String endpoint;

  @override
  Future<ReferralModel> getReferralInfo() async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(endpoint);
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ReferralModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<List<PointsTransactionModel>> getReferralTransactions() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(AppStrings.referralTransactionsURL);
      if (response.data is List<dynamic>) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> raw) => PointsTransactionModel.fromJson(
                Map<String, dynamic>.from(raw),
              ),
            )
            .toList();
      }
      if (response.data == null) {
        return <PointsTransactionModel>[];
      }
      throw const ServerException('Invalid response structure');
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<void> redeemCoupon(String code) async {
    try {
      await _client.post<dynamic>(
        AppStrings.redeemCouponURL,
        data: <String, dynamic>{
          'code': code.trim(),
        },
      );
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}

