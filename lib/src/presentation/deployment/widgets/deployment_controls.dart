import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/docker/docker_manager.dart';
import '../../../domain/enums/deployment_status.dart';
import '../../bloc/repository_bloc.dart';
import '../common/modern/gradient_buttons.dart';

class DeploymentControls extends StatelessWidget {
  final ValueNotifier<DeploymentStatus> status;
  final DockerService service;
  final VoidCallback startDeployment;
  final VoidCallback stopDeployment;
  final VoidCallback checkStatus;

  const DeploymentControls({
    super.key,
    required this.status,
    required this.service,
    required this.startDeployment,
    required this.stopDeployment,
    required this.checkStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoryBloc, RepositoryState>(
        builder: (context, state) {
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 12,
        runSpacing: 12,
        runAlignment: WrapAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: status,
            builder: (
              BuildContext context,
              DeploymentStatus status,
              Widget? child,
            ) {
              return GradientActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Iniciar Despliegue',
                enabledGradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                ),
                disabledGradient: const LinearGradient(
                  colors: [Color(0xFFA5D6A7), Color(0xFFC8E6C9)],
                ),
                useColorsForShadow: false,
                enabled: (status == DeploymentStatus.ready ||
                        status == DeploymentStatus.notWorking) &&
                    state.selection != null && state is RepositoryLoaded,
                onPressed: startDeployment,
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: service.isRunning,
            builder: (BuildContext context, bool value, Widget? child) {
              return GradientActionButton(
                icon: Icons.stop_rounded,
                label: 'Detener',
                useColorsForShadow: false,
                enabledGradient: const LinearGradient(
                  colors: [
                    Color(0xFFF44336),
                    Color(0xFFFF5252),
                  ],
                ),
                disabledGradient: LinearGradient(
                  colors: [
                    Colors.white12,
                    Colors.grey.withAlpha(90),
                  ],
                ),
                enabled: value,
                onPressed: stopDeployment,
              );
            },
          ),
          GradientActionButton(
            icon: Icons.refresh_rounded,
            label: 'Actualizar',
            useColorsForShadow: false,
            enabledGradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF03A9F4)],
            ),
            disabledGradient: const LinearGradient(
              colors: [Color(0xFF90CAF9), Color(0xFFB3E5FC)],
            ),
            enabled: state is RepositoryLoaded,
            onPressed: checkStatus,
          ),
        ],
      );
    });
  }
}
