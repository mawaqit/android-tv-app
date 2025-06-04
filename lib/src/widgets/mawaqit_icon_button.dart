import 'package:flutter/material.dart';

class MawaqitIconButton extends StatefulWidget {
  const MawaqitIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.focusNode,
    this.onPressed,
  }) : super(key: key);
  final IconData icon;
  final FocusNode focusNode;
  final String label;
  final VoidCallback? onPressed;
  @override
  State<MawaqitIconButton> createState() => _MawaqitIconButtonState();
}

class _MawaqitIconButtonState extends State<MawaqitIconButton> {
  bool focused = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary;

    return SizedBox(
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        color: theme.colorScheme.primary,
        elevation: 0,
        child: Focus(
          onFocusChange: (value) => setState(() => focused = value),
          child: Material(
            color: focused ? theme.focusColor : theme.colorScheme.primary,
            child: InkWell(
              focusNode: widget.focusNode,
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      widget.label,
                      style: theme.textTheme.bodySmall!.copyWith(color: focused ? Colors.white : color),
                    ),
                    SizedBox(width: 10),
                    Align(
                      alignment: Alignment(.5, 0),
                      child: Icon(widget.icon, color: focused ? Colors.white : color, size: 16),
                      widthFactor: .5,
                      heightFactor: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
