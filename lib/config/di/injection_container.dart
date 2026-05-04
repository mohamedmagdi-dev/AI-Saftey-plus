import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../../features/alerts/data/datasources/remote_alert_data_source.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/presentation/cubit/alert_cubit.dart';
import '../../features/auth/data/datasources/remote_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cameras/data/datasources/remote_camera_data_source.dart';
import '../../features/cameras/data/repositories/camera_repository_impl.dart';
import '../../features/cameras/domain/repositories/camera_repository.dart';
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

  getIt.registerFactory<AuthCubit>(() => AuthCubit(authRepository: getIt()));
  getIt.registerFactory<CameraCubit>(() => CameraCubit(cameraRepository: getIt()));
  getIt.registerFactory<AlertCubit>(() => AlertCubit(alertRepository: getIt()));
  getIt.registerFactory<ReportsCubit>(() => ReportsCubit(repository: getIt()));
}
