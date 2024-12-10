import 'package:flutter/material.dart';

class MawaqitBackIconButton extends StatefulWidget {
  const MawaqitBackIconButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onPressed,
  }) : super(key: key);
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<MawaqitBackIconButton> createState() => _MawaqitIconButtonState();
}

class _MawaqitIconButtonState extends State<MawaqitBackIconButton> {
  bool focused = false;

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
        child: InkWell(
          onTap: widget.onPressed,
          onFocusChange: (value) => setState(() => focused = value),
          focusColor: Color(0xFF490094),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                Align(
                  alignment: Alignment(.5, 0),
                  child: Icon(widget.icon, color: focused ? Colors.white : color, size: 16),
                  widthFactor: .5,
                  heightFactor: 1,
                ),
                SizedBox(width: 10),
                Text(
                  widget.label,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: focused ? Colors.white : color,
                    fontWeight: FontWeight.w700,
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
