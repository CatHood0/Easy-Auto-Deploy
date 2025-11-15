import 'package:auto_deployment/src/domain/enums/issue_severity.dart';

/// Información detallada sobre el problema de permisos
class PermissionIssue {
  final IssueSeverity severity;
  final String title;
  final String description;
  final String solution;

  PermissionIssue({
    required this.severity,
    required this.title,
    required this.description,
    required this.solution,
  });
}
