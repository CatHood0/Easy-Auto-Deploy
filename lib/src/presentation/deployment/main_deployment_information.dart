import 'package:flutter/material.dart';
import '../../data/services/docker/docker_manager.dart';
import 'common/stacktrace_codeblock_widget.dart';
import 'common/suggestion_widgets.dart';

class MainData extends StatefulWidget {
  const MainData({
    super.key,
    required this.dockerManager,
  });

  final DockerService dockerManager;

  @override
  State<MainData> createState() => _MainDataState();
}

class _MainDataState extends State<MainData> {
  final GlobalKey _stackTraceKey = GlobalKey();
  final GlobalKey _suggestionsKey = GlobalKey();
  bool forceFullScreenRegistry = false;

  late final Widget _stackTraceWidget;
  late final Widget _suggestionCommentsList;

  @override
  void initState() {
    super.initState();
    // to avoid contant rebuilds caused by
    // Viewport changes (LayoutBuilder)
    // we create just one time the widgets
    // to allow weird flickering
    _stackTraceWidget = RepaintBoundary(
      child: StackTraceCodeBlock(
        key: _stackTraceKey,
        logs: widget.dockerManager.logs,
      ),
    );
    _suggestionCommentsList = RepaintBoundary(
      child: SuggestionCommentsList(
        key: _suggestionsKey,
        service: widget.dockerManager,
        noSuggestions: noSuggestions,
      ),
    );
  }

  void noSuggestions() {
    if (mounted) {
      setState(() {
        forceFullScreenRegistry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _suggestionCommentsList,
        _stackTraceWidget,
      ],
    );
  }
}
