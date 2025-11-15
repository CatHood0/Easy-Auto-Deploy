import 'package:auto_deployment/src/domain/repository/repo_provider_repository.dart';
import 'package:auto_deployment/src/presentation/deployment/widgets/deployment_build_options.dart';
import 'package:auto_deployment/src/presentation/deployment/widgets/deployment_controls.dart';
import 'package:auto_deployment/src/presentation/deployment/widgets/repository_selector.dart';
import 'package:provider/provider.dart';

import '../../data/services/docker/docker_manager.dart';
import '../../domain/enums/deployment_status.dart';
import 'package:flutter/material.dart';

import 'main_deployment_information.dart';

class DockerDeploymentScreen extends StatelessWidget {
  const DockerDeploymentScreen({
    super.key,
    required this.status,
    required this.useFullBuild,
    required this.cloneProjectAlways,
    required this.repository,
    required this.checkStatus,
    required this.startDeployment,
    required this.stopDeployment,
  });

  final ValueNotifier<DeploymentStatus> status;
  final ValueNotifier<bool> useFullBuild;
  final ValueNotifier<bool> cloneProjectAlways;
  final RepoProviderRepository repository;
  final Future<void> Function() checkStatus;
  final Future<void> Function() startDeployment;
  final Future<void> Function() stopDeployment;

  @override
  Widget build(BuildContext context) {
    final DockerService service = Provider.of<DockerService>(
      context,
      listen: true,
    );
    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepositorySelectorWidget(),
                  const SizedBox(height: 16),
                  DeploymentBuildOptions(
                    useFullBuild: useFullBuild,
                    cloneFullProject: cloneProjectAlways,
                  ),
                  const SizedBox(height: 16),
                  DeploymentControls(
                    status: status,
                    service: service,
                    startDeployment: startDeployment,
                    stopDeployment: stopDeployment,
                    checkStatus: checkStatus,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          MainData(
            dockerManager: service,
          ),
        ],
      ),
    );
  }
}
