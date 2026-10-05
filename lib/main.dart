import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/classification/presentation/bloc/classification_bloc.dart';
import 'features/comparison/presentation/bloc/compare_cubit.dart';
import 'features/explorer/presentation/bloc/explorer_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await di.init();
  runApp(const NanaDocApp());
}

class NanaDocApp extends StatefulWidget {
  const NanaDocApp({super.key});

  @override
  State<NanaDocApp> createState() => _NanaDocAppState();
}

class _NanaDocAppState extends State<NanaDocApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ClassificationBloc>(
          create: (_) => di.sl<ClassificationBloc>()..add(LoadClassification()),
        ),
        BlocProvider<ExplorerCubit>(create: (_) => ExplorerCubit()),
        BlocProvider<CompareCubit>(create: (_) => CompareCubit()),
      ],
      child: MaterialApp.router(
        title: 'Nana Doc',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
