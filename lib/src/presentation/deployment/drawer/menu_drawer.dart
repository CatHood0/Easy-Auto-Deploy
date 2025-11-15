import 'package:auto_deployment/src/data/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../domain/enums/deployment_status.dart';
import '../../../utils/status_colors.dart';

class ModernDrawer extends StatelessWidget {
  const ModernDrawer({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
    required this.deploymentStatus,
  });

  final DrawerPage currentPage;
  final ValueChanged<DrawerPage> onPageSelected;
  final ValueListenable<DeploymentStatus> deploymentStatus;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(0),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withAlpha(70),
              Theme.of(context).colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: Column(
          children: [
            DrawerHeaderSection(
              deploymentStatus: deploymentStatus,
            ),
            const SizedBox(height: 16),
            DrawerMenuItems(
              currentPage: currentPage,
              onPageSelected: onPageSelected,
            ),
            const Spacer(),
            DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class DrawerHeaderSection extends StatelessWidget {
  const DrawerHeaderSection({
    super.key,
    required this.deploymentStatus,
  });

  final ValueListenable<DeploymentStatus> deploymentStatus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeploymentStatus>(
      valueListenable: deploymentStatus,
      builder: (context, status, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                getStatusColor(status).withOpacity(0.8),
                getStatusColor(status).withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                Constant.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'JetBrains Mono NF',
                  fontFamilyFallback: ['Monospace', 'Consolas'],
                ),
              ),
              const SizedBox(height: 4),
              StatusSubtitle(status: status),
            ],
          ),
        );
      },
    );
  }
}

class StatusSubtitle extends StatelessWidget {
  const StatusSubtitle({
    super.key,
    required this.status,
  });

  final DeploymentStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      _getStatusText(status),
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.8),
        fontFamily: 'JetBrains Mono NF',
        fontFamilyFallback: ['Monospace', 'Consolas'],
      ),
    );
  }

  String _getStatusText(DeploymentStatus status) {
    switch (status) {
      case DeploymentStatus.running:
        return 'Despliegue activo';
      case DeploymentStatus.ready:
        return 'Listo para desplegar';
      case DeploymentStatus.error:
        return 'Error en el sistema';
      case DeploymentStatus.requireDocker:
        return 'Docker requerido';
      default:
        return 'Sistema de despliegue automático';
    }
  }
}

class DrawerMenuItems extends StatelessWidget {
  const DrawerMenuItems({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  final DrawerPage currentPage;
  final ValueChanged<DrawerPage> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          DrawerMenuItem(
            icon: Icons.rocket_launch_rounded,
            title: 'Despliegue',
            page: DrawerPage.deployment,
            currentPage: currentPage,
            onTap: onPageSelected,
          ),
          const SizedBox(height: 8),
          DrawerMenuItem(
            icon: Icons.storage_rounded,
            title: 'Repositorios',
            page: DrawerPage.repositories,
            currentPage: currentPage,
            onTap: onPageSelected,
          ),
          const SizedBox(height: 8),
          DrawerMenuItem(
            icon: Icons.integration_instructions,
            title: 'Integraciones',
            page: DrawerPage.repositories,
            currentPage: currentPage,
            onTap: onPageSelected,
          ),
          const SizedBox(height: 8),
          DrawerMenuItem(
            icon: Icons.settings_rounded,
            title: 'Configuración',
            page: DrawerPage.settings,
            currentPage: currentPage,
            onTap: onPageSelected,
          ),
        ],
      ),
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.page,
    required this.currentPage,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final DrawerPage page;
  final DrawerPage currentPage;
  final ValueChanged<DrawerPage> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPage == page;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontFamily: 'JetBrains Mono NF',
            fontFamilyFallback: ['Monospace', 'Consolas'],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () => onTap(page),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            '${Constant.appName} ${Constant.version}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontFamily: 'JetBrains Mono NF',
              fontFamilyFallback: ['Monospace', 'Consolas'],
            ),
          ),
        ],
      ),
    );
  }
}

enum DrawerPage {
  deployment,
  repositories,
  integrations,
  settings,
}
