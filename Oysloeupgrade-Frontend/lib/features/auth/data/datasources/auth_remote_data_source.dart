import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecase/login_params.dart';
import '../../../../core/usecase/reset_password_params.dart';
import '../../../../core/usecase/register_params.dart';
import '../../../../core/usecase/update_profile_params.dart';
import '../../../../core/utils/api_helper.dart';
import '../models/auth_session_model.dart';
import '../models/reset_password_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> register(RegisterParams params);
  Future<AuthSessionModel> login(LoginParams params);
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordParams params);
  Future<AuthUserModel> fetchProfile();
  Future<AuthUserModel> updateProfile(UpdateProfileParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required Dio client,
    this.registerEndpoint = AppStrings.registerURL,
    this.loginEndpoint = AppStrings.loginURL,
    this.resetPasswordEndpoint = AppStrings.resetPasswordURL,
    this.userProfileEndpoint = AppStrings.userProfileURL,
  }) : _client = client;

  final Dio _client;
  final String registerEndpoint;
  final String loginEndpoint;
  final String resetPasswordEndpoint;
  final String userProfileEndpoint;

  @override
  Future<AuthSessionModel> register(RegisterParams params) async {
    return _post(registerEndpoint, params.toJson());
  }

  @override
  Future<AuthSessionModel> login(LoginParams params) async {
    return _post(loginEndpoint, params.toJson());
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordParams params,
  ) async {
    try {
      final Options? options = params.token.isEmpty
          ? null
          : Options(
              headers: <String, dynamic>{
                'Authorization': 'Token ${params.token}',
              },
            );
      final Response<dynamic> response = await _client.post<dynamic>(
        resetPasswordEndpoint,
        data: params.toJson(),
        options: options,
      );
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return ResetPasswordResponseModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AuthUserModel> fetchProfile() async {
    try {
      final Response<dynamic> response =
          await _client.get<dynamic>(userProfileEndpoint);
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return AuthUserModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Future<AuthUserModel> updateProfile(UpdateProfileParams params) async {
    try {
      final FormData formData = FormData.fromMap(params.toJson());

      Future<void> addFile(String field, String? path) async {
        if (path == null || path.isEmpty) return;
        try {
          if (kIsWeb) {
            final XFile xfile = XFile(path);
            final List<int> bytes = await xfile.readAsBytes();
            String filename = xfile.name;
            if (filename.isEmpty) {
              final Uri uri = Uri.parse(path);
              filename = uri.pathSegments.isNotEmpty
                  ? uri.pathSegments.last
                  : 'upload_$field.png';
            }
            if (!filename.contains('.')) {
              filename = '$filename.png';
            }
            formData.files.add(
              MapEntry(
                field,
                MultipartFile.fromBytes(
                  bytes,
                  filename: filename,
                ),
              ),
            );
          } else {
            final String filename = path.split(RegExp(r'[\/\\]')).last;
            formData.files.add(
              MapEntry(
                field,
                await MultipartFile.fromFile(
                  path,
                  filename: filename.isEmpty ? 'upload_$field.png' : filename,
                ),
              ),
            );
          }
        } catch (error) {
          throw ApiException('Failed to attach file for $field');
        }
      }

      await addFile('avatar', params.avatarFilePath);
      await addFile('business_logo', params.businessLogoFilePath);
      await addFile('id_front_page', params.idFrontFilePath);
      await addFile('id_back_page', params.idBackFilePath);

      final Response<dynamic> response = await _client.put<dynamic>(
        userProfileEndpoint,
        data: formData,
      );
      final Map<String, dynamic> data = ApiHelper.extractPayload(response);
      return AuthUserModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException(ApiHelper.getHumanReadableMessage(error));
    } on ServerException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  Future<AuthSessionModel> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final Response<dynamic> response =
          await _client.post<dynamic>(endpoint, data: payload);
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
