import 'package:flutter/material.dart';

import '../domain/enums/deployment_status.dart';

Color getStatusColor(DeploymentStatus status) {
  switch (status) {
    case DeploymentStatus.idle:
      return const Color(0xFFFFB74D); // Amber 300 - Para estado en espera
    case DeploymentStatus.ready:
      return const Color(0xFF42A5F5); // Blue 400 - Listo para acción
    case DeploymentStatus.cloning:
      return const Color(0xFF29B6F6); // Light Blue 400 - Proceso activo
    case DeploymentStatus.notWorking:
      return const Color(
          0xFF5C6BC0); // Indigo 400 - Estado neutral/problemático
    case DeploymentStatus.running:
      return const Color(0xFF66BB6A); // Green 400 - Éxito/proceso funcionando
    case DeploymentStatus.error:
      return const Color(0xFFEF5350); // Red 400 - Error claro
    case DeploymentStatus.unusable:
      return const Color(0xFF8D6E63); // Brown 400 - Estado crítico
    case DeploymentStatus.requireExternalService:
    case DeploymentStatus.requireDocker:
      return const Color(0xFFFF7043); // Deep Orange 400 - Requiere atención
  }
}
