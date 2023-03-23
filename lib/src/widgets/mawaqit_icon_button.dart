import 'package:flutter/material.dart';

class MawaqitIconButton extends StatefulWidget {
  const MawaqitIconButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String label;

  final VoidCallback? onPressed;

  @override
  State<MawaqitIconButton> createState() => _MawaqitIconButtonState();
}

class _MawaqitIconButtonState extends State<MawaqitIconButton> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.colorScheme.onPrimary;

    return SizedBox(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        color: theme.colorScheme.primary,
        elevation: 0,
        child: InkWell(
          onTap: widget.onPressed,
          onFocusChange: (value) => setState(() => focused = value),
          focusColor: color.withOpacity(.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.bodySmall!.copyWith(color: color),
                ),
                SizedBox(width: 10),
                Align(
                  alignment: Alignment(.5, 0),
                  child: Icon(widget.icon, color: color, size: 16),
                  widthFactor: .5,
                  heightFactor: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
