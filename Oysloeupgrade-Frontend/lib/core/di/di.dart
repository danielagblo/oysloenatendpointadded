part of 'dependency_injection.dart';

Future<void> _initCore() async {
  sl
    ..registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.instance,
    )
    ..registerLazySingleton<Network>(
      () => NetworkImpl(sl()),
    )
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppStrings.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          contentType: 'application/json',
        ),
      );

      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );

      return dio;
    });
}

Future<void> _initAuth() async {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(box: sl(instanceName: 'auth_box')),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<OtpRemoteDataSource>(
      () => OtpRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        otpRemoteDataSource: sl(),
        network: sl(),
        client: sl(),
      ),
    )
    ..registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(sl()),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(sl()),
    )
    ..registerLazySingleton<GetCachedSessionUseCase>(
      () => GetCachedSessionUseCase(sl()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(sl()),
    )
    ..registerLazySingleton<SendOtpUseCase>(
      () => SendOtpUseCase(sl()),
    )
    ..registerLazySingleton<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(sl()),
    )
    ..registerLazySingleton<VerifyResetOtpUseCase>(
      () => VerifyResetOtpUseCase(sl()),
    )
    ..registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(sl()),
    )
    ..registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(sl()),
    )
    ..registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(sl()),
    )
    ..registerFactory<RegisterCubit>(
      () => RegisterCubit(sl()),
    )
    ..registerFactory<LoginCubit>(
      () => LoginCubit(sl(), sl()),
    )
    ..registerFactory<OtpCubit>(
      () => OtpCubit(sl(), sl()),
    )
    ..registerFactory<PasswordResetCubit>(
      () => PasswordResetCubit(sl(), sl(), sl()),
    );

  await sl<GetCachedSessionUseCase>()(const NoParams());
}

Future<void> _initDashboard() async {
  sl
    ..registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<CategoriesLocalDataSource>(
      () => CategoriesLocalDataSourceImpl(
        box: sl(instanceName: 'categories_box'),
      ),
    )
    ..registerLazySingleton<AlertsRemoteDataSource>(
      () => AlertsRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<AccountDeleteRequestsRemoteDataSource>(
      () => AccountDeleteRequestsRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(client: sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: sl(),
        categoriesRemoteDataSource: sl(),
        categoriesLocalDataSource: sl(),
        alertsRemoteDataSource: sl(),
        accountDeleteRequestsRemoteDataSource: sl(),
        chatRemoteDataSource: sl(),
        network: sl(),
      ),
    )
    ..registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(sl()),
    )
    ..registerLazySingleton<GetProductReviewsUseCase>(
      () => GetProductReviewsUseCase(sl()),
    )
    ..registerLazySingleton<GetProductDetailUseCase>(
      () => GetProductDetailUseCase(sl()),
    )
    ..registerLazySingleton<ReportProductUseCase>(
      () => ReportProductUseCase(sl()),
    )
    ..registerLazySingleton<GetRelatedProductsUseCase>(
      () => GetRelatedProductsUseCase(sl()),
    )
    ..registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(sl()),
    )
    ..registerLazySingleton<GetAlertsUseCase>(
      () => GetAlertsUseCase(sl()),
    )
    ..registerLazySingleton<MarkProductAsTakenUseCase>(
      () => MarkProductAsTakenUseCase(sl()),
    )
    ..registerLazySingleton<SetProductStatusUseCase>(
      () => SetProductStatusUseCase(sl()),
    )
    ..registerLazySingleton<DeleteProductUseCase>(
      () => DeleteProductUseCase(sl()),
    )
    ..registerLazySingleton<MarkAlertReadUseCase>(
      () => MarkAlertReadUseCase(sl()),
    )
    ..registerLazySingleton<DeleteAlertUseCase>(
      () => DeleteAlertUseCase(sl()),
    )
    ..registerLazySingleton<CreateReviewUseCase>(
      () => CreateReviewUseCase(sl()),
    )
    ..registerLazySingleton<UpdateReviewUseCase>(
      () => UpdateReviewUseCase(sl()),
    )
    ..registerLazySingleton<CreateProductUseCase>(
      () => CreateProductUseCase(sl()),
    )
    ..registerLazySingleton<GetAccountDeleteRequestsUseCase>(
      () => GetAccountDeleteRequestsUseCase(sl()),
    )
    ..registerLazySingleton<CreateAccountDeleteRequestUseCase>(
      () => CreateAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<GetAccountDeleteRequestUseCase>(
      () => GetAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<UpdateAccountDeleteRequestUseCase>(
      () => UpdateAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<DeleteAccountDeleteRequestUseCase>(
      () => DeleteAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<ApproveAccountDeleteRequestUseCase>(
      () => ApproveAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<RejectAccountDeleteRequestUseCase>(
      () => RejectAccountDeleteRequestUseCase(sl()),
    )
    ..registerLazySingleton<GetOrCreateChatRoomIdUseCase>(
      () => GetOrCreateChatRoomIdUseCase(sl()),
    )
    ..registerLazySingleton<GetChatRoomsUseCase>(
      () => GetChatRoomsUseCase(sl()),
    )
    ..registerLazySingleton<GetChatMessagesUseCase>(
      () => GetChatMessagesUseCase(sl()),
    )
    ..registerLazySingleton<SendChatMessageUseCase>(
      () => SendChatMessageUseCase(sl()),
    )
    ..registerLazySingleton<MarkChatRoomReadUseCase>(
      () => MarkChatRoomReadUseCase(sl()),
    )
    ..registerFactory<ProductsCubit>(
      () => ProductsCubit(sl(), sl()),
    )
    ..registerFactory<ChatCubit>(
      () => ChatCubit(
        sl<GetChatMessagesUseCase>(),
        sl<SendChatMessageUseCase>(),
        sl<MarkChatRoomReadUseCase>(),
      ),
    )
    ..registerFactory<CategoriesCubit>(
      () => CategoriesCubit(sl()),
    )
    ..registerFactory<AlertsCubit>(
      () => AlertsCubit(sl(), sl(), sl()),
    )
    ..registerFactory<AccountDeleteCubit>(
      () => AccountDeleteCubit(
        sl<GetAccountDeleteRequestsUseCase>(),
        sl<CreateAccountDeleteRequestUseCase>(),
      ),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(
        sl<GetCachedSessionUseCase>(),
        sl<GetProfileUseCase>(),
        sl<UpdateProfileUseCase>(),
      ),
    );
}
