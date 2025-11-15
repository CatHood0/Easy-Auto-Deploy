import 'package:auto_deployment/src/domain/enums/issue_severity.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../data/services/docker/docker_manager.dart';
import '../../../domain/entities/permission_issue.dart';
import '../../widgets/shimmer_placeholder.dart';

class SuggestionCommentsList extends StatefulWidget {
  const SuggestionCommentsList({
    super.key,
    required this.service,
    required this.noSuggestions,
  });

  final DockerService service;
  final VoidCallback noSuggestions;

  @override
  State<SuggestionCommentsList> createState() => _SuggestionCommentsListState();
}

class _SuggestionCommentsListState extends State<SuggestionCommentsList> {
  List<PermissionIssue> _lastCacheIssues = <PermissionIssue>[];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PermissionIssue>>(
      future: widget.service.getListOfPermissionIssues(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<PermissionIssue>> asyncSnapshot,
      ) {
        if (asyncSnapshot.hasError ||
            (asyncSnapshot.hasData && (asyncSnapshot.data?.isEmpty ?? false))) {
          return const SizedBox();
        }

        final List<PermissionIssue> result = <PermissionIssue>[
          ...(asyncSnapshot.data ?? _lastCacheIssues),
        ].where((p) => p.severity != IssueSeverity.none).toList();
        if (asyncSnapshot.data != null) {
          _lastCacheIssues = result;
        }

        // Horizontal layout
        if (asyncSnapshot.connectionState == ConnectionState.waiting &&
            result.isEmpty) {
          return SizedBox(
            width: 300,
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                child: const LoadingSuggestions(
                  generalPadding: 0,
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...result.map(
                  (PermissionIssue p) => SliverPadding(
                    padding: const EdgeInsetsDirectional.only(bottom: 4),
                    sliver: SuggestionCommentWidget(
                      title: p.title,
                      message: '${p.description}\n'
                          '\n${p.solution}',
                      level: p.severity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoadingSuggestions extends StatelessWidget {
  final double generalPadding;
  const LoadingSuggestions({
    super.key,
    this.generalPadding = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(generalPadding),
      child: SizedBox(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            return DefaultShimmerTile(
              child: SuggestionCommentWidget(
                title: '',
                message: '',
                titleWidget: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder(
                          width: constraints.maxWidth * 0.14,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            right: 20,
                          ),
                          child: ShimmerPlaceholder(
                            width: constraints.maxWidth * 0.20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                level: IssueSeverity.none,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SuggestionCommentWidget extends StatelessWidget {
  final String message;
  final IssueSeverity level;
  final String title;
  final bool canReceivedGestures;
  final bool noIcon;
  final Widget? titleWidget;
  final Widget? messageWidget;

  const SuggestionCommentWidget({
    super.key,
    required this.title,
    required this.message,
    required this.level,
    this.titleWidget,
    this.messageWidget,
    this.canReceivedGestures = true,
    this.noIcon = false,
  });

  (IconData, Color) _getSeverityStyle(IssueSeverity level) {
    switch (level) {
      case IssueSeverity.critical:
        return (
          Icons.error_outline_rounded,
          const Color(0xFFE57373)
        ); // Colors.red[400]
      case IssueSeverity.warning:
        return (
          Icons.warning_amber_rounded,
          const Color(0xFFFFB74D)
        ); // Colors.orange[300]
      case IssueSeverity.none:
        return (
          Icons.lightbulb_outline_rounded,
          Colors.grey.withAlpha(30),
        ); // Colors.green[300]
    }
  }

  void _showSuggestionDialog(
    BuildContext context, {
    required ThemeData theme,
    required Color color,
    required IconData iconData,
  }) {
    if (!canReceivedGestures) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3C3C3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: color.withAlpha(154),
              width: 1,
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: color, size: 24),
              const SizedBox(width: 12),
              if (titleWidget != null)
                titleWidget!
              else
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          content: SelectableRegion(
            focusNode: FocusNode(),
            selectionControls: DesktopTextSelectionControls(),
            child: messageWidget ??
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: color),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData iconData, Color color) = _getSeverityStyle(level);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSuggestionDialog(
          context,
          theme: theme,
          color: color,
          iconData: iconData,
        ),
        borderRadius: BorderRadius.circular(8.0),
        hoverColor: color.withOpacity(0.25),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.0),
            border: Border(
              left: BorderSide(
                color: color,
                width: 5.0,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!noIcon)
                Icon(
                  iconData,
                  color: color,
                  size: 24,
                ),
              const SizedBox(width: 12),
              if (titleWidget != null)
                titleWidget!
              else
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
