import 'package:flutter/material.dart';

class StandardButton extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Icon? icon;
  final VoidCallback onPress;
  final void Function(VoidCallback forceRebuild)? rebuild;
  final String backgroundColor;

  const StandardButton({
    super.key,
    required this.text,
    required this.style,
    this.icon,
    required this.onPress,
    this.rebuild,
    required this.backgroundColor,
  });

  @override
  State<StandardButton> createState() => _StandardButtonState();
}

class _StandardButtonState extends State<StandardButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPress,
      child: Text(''),
    );
  }
}
