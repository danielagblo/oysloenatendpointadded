import 'package:dio/dio.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecase/otp_params.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/auth_session_model.dart';
import '../models/otp_model.dart';

abstract class OtpRemoteDataSource {
  Future<OtpResponseModel> sendOtp(SendOtpParams params);
  Future<OtpResponseModel> validateOtp(VerifyOtpParams params);
  Future<AuthSessionModel> verifyOtp(VerifyOtpParams params);
}

class OtpRemoteDataSourceImpl implements OtpRemoteDataSource {
  OtpRemoteDataSourceImpl({
    required Dio client,
    this.sendEndpoint = AppStrings.otpURL,
    this.validateEndpoint = AppStrings.otpURL,
    this.verifyEndpoint = AppStrings.otpLoginURL,
  }) : _client = client;

  final Dio _client;
  final String sendEndpoint;
  final String validateEndpoint;
  final String verifyEndpoint;

  @override
  Future<OtpResponseModel> sendOtp(SendOtpParams params) async {
    try {
      final Response<dynamic> response = await _client.get<dynamic>(
        sendEndpoint,
        queryParameters: params.toQueryParams(),
      );
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return OtpResponseModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getDioExceptionMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<OtpResponseModel> validateOtp(VerifyOtpParams params) async {
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(validateEndpoint, data: params.toJson());
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return OtpResponseModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp(VerifyOtpParams params) async {
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(verifyEndpoint, data: params.toJson());
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return AuthSessionModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
