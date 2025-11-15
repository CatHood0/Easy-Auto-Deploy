import 'package:auto_deployment/src/data/repository/repo_provider_repository.dart';
import 'package:auto_deployment/src/data/services/db/database_provider.dart';
import 'package:auto_deployment/src/data/services/docker/docker_manager.dart';
import 'package:auto_deployment/src/data/services/logger/logger_service.dart';
import 'package:auto_deployment/src/domain/entities/deployment_preferences.dart';
import 'package:auto_deployment/src/presentation/bloc/repository_bloc.dart';
import 'package:auto_deployment/src/presentation/shared_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeploymentPreferences.setup();
  await DeploymentProvider.instance.setup();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LoggerService _logger = LoggerService();

  @override
  void dispose() {
    _logger.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<RepositoryBloc>(
          create: (BuildContext ctx) => RepositoryBloc(
            RepoProviderRepositoryImpl(),
          ),
        ),
      ],
      child: Provider<DockerService>(
        create: (BuildContext ctx) => DockerService(_logger),
        lazy: false,
        child: MaterialApp(
          title: 'Auto Deployment',
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          showSemanticsDebugger: false,
          theme: ThemeData.dark(),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
