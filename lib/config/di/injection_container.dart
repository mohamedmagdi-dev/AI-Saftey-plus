import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/token_storage.dart';
import '../../features/alerts/data/datasources/remote_alert_data_source.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/domain/usecases/get_alert_history_usecase.dart';
import '../../features/alerts/domain/usecases/listen_to_alerts_usecase.dart';
import '../../features/alerts/domain/usecases/get_alert_by_id_usecase.dart';
import '../../features/alerts/domain/usecases/send_notification_usecase.dart';
import '../../features/alerts/presentation/cubit/alert_cubit.dart';
import '../../features/auth/data/datasources/remote_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cameras/data/datasources/remote_camera_data_source.dart';
import '../../features/cameras/data/repositories/camera_repository_impl.dart';
import '../../features/cameras/domain/repositories/camera_repository.dart';
import '../../features/cameras/domain/usecases/get_cameras_usecase.dart';
import '../../features/cameras/domain/usecases/get_camera_by_id_usecase.dart';
import '../../features/cameras/domain/usecases/get_stream_url_usecase.dart';
import '../../features/cameras/domain/usecases/get_camera_snapshot_usecase.dart';
import '../../features/cameras/presentation/cubit/camera_cubit.dart';
import '../../features/reports/data/datasources/remote_reports_data_source.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  final tokenStorage = await TokenStorage.create();
  getIt.registerSingleton<TokenStorage>(tokenStorage);

  getIt.registerLazySingleton<Dio>(() => createDio(getIt()));

  getIt.registerLazySingleton<RemoteAuthDataSource>(
    () => RemoteAuthDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), tokenStorage: getIt()),
  );

  getIt.registerLazySingleton<RemoteCameraDataSource>(
    () => RemoteCameraDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(remote: getIt()),
  );

  getIt.registerLazySingleton<RemoteAlertDataSource>(
    () => RemoteAlertDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(remote: getIt()),
  );

  getIt.registerLazySingleton<RemoteReportsDataSource>(
    () => RemoteReportsDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(remote: getIt()),
  );

  // Register Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Register UseCases
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt()));
  
  getIt.registerLazySingleton<GetCamerasUseCase>(() => GetCamerasUseCase(getIt()));
  getIt.registerLazySingleton<GetCameraByIdUseCase>(() => GetCameraByIdUseCase(getIt()));
  getIt.registerLazySingleton<GetStreamUrlUseCase>(() => GetStreamUrlUseCase(getIt()));
  getIt.registerLazySingleton<GetCameraSnapshotUseCase>(() => GetCameraSnapshotUseCase(getIt()));
  
  getIt.registerLazySingleton<GetAlertHistoryUseCase>(() => GetAlertHistoryUseCase(getIt()));
  getIt.registerLazySingleton<ListenToAlertsUseCase>(() => ListenToAlertsUseCase(getIt()));
  getIt.registerLazySingleton<GetAlertByIdUseCase>(() => GetAlertByIdUseCase(getIt()));
  getIt.registerLazySingleton<SendNotificationUseCase>(() => SendNotificationUseCase(getIt<NotificationService>()));

  // Register Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(
    authRepository: getIt(),
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
  ));
  getIt.registerFactory<CameraCubit>(() => CameraCubit(
    cameraRepository: getIt(),
    getCamerasUseCase: getIt(),
    getCameraByIdUseCase: getIt(),
    getStreamUrlUseCase: getIt(),
    getCameraSnapshotUseCase: getIt(),
  ));
  getIt.registerFactory<AlertCubit>(() => AlertCubit(
    alertRepository: getIt(),
    getAlertHistoryUseCase: getIt(),
    listenToAlertsUseCase: getIt(),
    getAlertByIdUseCase: getIt(),
    sendNotificationUseCase: getIt(),
  ));
  getIt.registerFactory<ReportsCubit>(() => ReportsCubit(repository: getIt()));
}
