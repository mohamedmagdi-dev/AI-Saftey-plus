import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/di/injection_container.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/cubit/navigation_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cameras/presentation/cubit/camera_cubit.dart';
import 'features/alerts/presentation/cubit/alert_cubit.dart';
import 'features/reports/presentation/cubit/reports_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(create: (_) => getIt<CameraCubit>()),
        BlocProvider(create: (_) => getIt<AlertCubit>()),
        BlocProvider(create: (_) => getIt<ReportsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'AI Safety+',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
