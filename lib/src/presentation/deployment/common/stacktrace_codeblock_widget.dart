import 'package:auto_deployment/src/presentation/widgets/shimmer_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_md/flutter_md.dart';

class StackTraceCodeBlock extends StatefulWidget {
  const StackTraceCodeBlock({
    super.key,
    required this.logs,
  });

  final Stream<List<String>> logs;

  @override
  State<StackTraceCodeBlock> createState() => _StackTraceCodeBlockState();
}

class _StackTraceCodeBlockState extends State<StackTraceCodeBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro de Actividad',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.5,
            ),
            overflow: TextOverflow.clip,
            maxLines: 2,
          ),
          Text(
            'Historial en tiempo real de operaciones',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xEEFFFFFF),
            ),
            overflow: TextOverflow.clip,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 400,
            child: StreamBuilder(
              stream: widget.logs,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<String>> asyncSnapshot,
              ) {
                if (asyncSnapshot.hasError ||
                    asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultCodeBlockShimmerPlaceholder(),
                    ],
                  );
                }
                return ListView.builder(
                  addRepaintBoundaries: true,
                  itemCount: asyncSnapshot.requireData.length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final String log = asyncSnapshot.requireData[index];
                    int tIndex = log.indexOf(']:');
                    final String logMessage = log.substring(
                      tIndex + 2,
                    );
                    return StacktraceLogTile(
                      log: log,
                      tIndex: tIndex,
                      logMessage: logMessage,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DefaultCodeBlockShimmerPlaceholder extends StatelessWidget {
  const DefaultCodeBlockShimmerPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultShimmerTile(
      child: ShimmerPlaceholder(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerPlaceholder(
                width: 300,
                height: 10,
              ),
              const SizedBox(height: 4),
              ShimmerPlaceholder(
                width: 450,
                height: 10,
              ),
              const SizedBox(height: 4),
              ShimmerPlaceholder(
                width: 400,
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StacktraceLogTile extends StatefulWidget {
  const StacktraceLogTile({
    super.key,
    required this.log,
    required this.tIndex,
    required this.logMessage,
  });

  final String log;
  final int tIndex;
  final String logMessage;

  @override
  State<StacktraceLogTile> createState() => _StacktraceLogTileState();
}

class _StacktraceLogTileState extends State<StacktraceLogTile> {
  bool _expanded = false;
  bool _firstAutoExpand = false;
  @override
  Widget build(BuildContext context) {
    final bool isInstallationError = widget.log.contains(
      RegExp(
        r'(❌|🛑|🚫)',
        unicode: true,
      ),
    );
    final bool isTip = widget.log.contains(
      RegExp(
        r'💡',
        unicode: true,
      ),
    );
    // we always prefer auto-expanding tips
    if (isTip && !_firstAutoExpand) {
      _expanded = true;
      _firstAutoExpand = true;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.circular(10),
        ),
        animateColor: true,
        color: isTip ? Colors.blue.withAlpha(40) : Colors.grey.withAlpha(30),
        borderOnForeground: true,
        child: InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          borderRadius: BorderRadius.circular(
            10,
          ),
          focusColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.log.substring(0, widget.tIndex + 1),
                  style: TextStyle(
                    color: isInstallationError
                        ? Colors.red
                        : isTip
                            ? Colors.blue.shade200
                            : Colors.lightBlueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono NF',
                    fontFamilyFallback: [
                      'Monospace',
                      'Consolas',
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '›',
                  style: TextStyle(
                    color: isInstallationError
                        ? Colors.red
                        : isTip
                            ? Colors.blue.shade200
                            : Colors.lightBlueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: SelectableRegion(
                    selectionControls: DesktopTextSelectionControls(),
                    child: Text(
                      widget.logMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Monospace',
                      ),
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      maxLines: _expanded ? null : 1,
                      softWrap: _expanded,
                      textScaler: MediaQuery.textScalerOf(context),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                MaterialButton(
                  onPressed: () {
                    _expanded = !_expanded;
                    setState(() {});
                  },
                  minWidth: 10,
                  color: Colors.grey.withAlpha(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      7,
                    ),
                  ),
                  child: Icon(
                    !_expanded ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MarkdownText extends StatelessWidget {
  final String markdown;
  const MarkdownText({
    super.key,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownTheme(
      data: MarkdownThemeData(
        textStyle: TextStyle(fontSize: 16.0, color: Colors.black87),
        h1Style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        h2Style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
        quoteStyle: TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
        textDirection: TextDirection.ltr,
        // Handle link taps
        onLinkTap: (title, url) {
          // print('Tapped link: $title -> $url');
          // Launch URL or navigate
        },
        // Filter spans (e.g., exclude certain styles)
        spanFilter: (span) => !span.style.contains(MD$Style.spoiler),
      ),
      child: MarkdownWidget(
        markdown: Markdown.fromString(markdown),
      ),
    );
  }
}
