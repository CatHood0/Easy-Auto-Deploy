import 'package:flutter/material.dart';

import '../../../domain/enums/deployment_status.dart';

class StatusIndicator extends StatefulWidget {
  const StatusIndicator({
    super.key,
    required this.color,
    required this.status,
    this.fontSize = 16,
  });

  final double fontSize;
  final Color color;
  final ValueNotifier<DeploymentStatus> status;

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> {
  final Map<DeploymentStatus, (String, Color)> statusInfo = {
    DeploymentStatus.idle: ('Verificando Docker...', Colors.orange),
    DeploymentStatus.ready: ('Listo para desplegar', Colors.green),
    DeploymentStatus.cloning: ('Clonando repositorio...', Colors.blue),
    DeploymentStatus.running: ('Contenedores en ejecución', Colors.green),
    DeploymentStatus.error: ('Error', Colors.red),
    DeploymentStatus.unusable: ('No usable', Colors.black),
    DeploymentStatus.notWorking: ('Esperando', Colors.black),
  };
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.status,
        builder: (
          BuildContext context,
          DeploymentStatus value,
          Widget? child,
        ) {
          final (String message, Color color) = statusInfo[value]!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ],
          );
        });
  }
}
