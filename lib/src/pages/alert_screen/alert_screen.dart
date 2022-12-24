import 'package:flutter/material.dart';

/// alert screen used to view all alerts like (adhan, iqamaa, etc)
class AlertScreen extends StatefulWidget {
  const AlertScreen({
    Key? key,
    required this.title,
    required this.icon,
    this.duration = const Duration(minutes: 2),
    this.secondaryIcon,
    this.subTitle,
    this.additional,
  }) : super(key: key);

  final Duration duration;
  final String title;
  final String? subTitle;
  final String? additional;
  final Widget icon;
  final Widget? secondaryIcon;

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  @override
  void initState() {
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/splash_screen_5.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      // transform: GradientRotation(pi / 2),
                      begin: Alignment(0, 0),
                      end: Alignment(0, 1),
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      if (widget.subTitle != null)
                        Text(
                          widget.subTitle!,
                          style: theme.textTheme.displaySmall,
                        ),
                      if (widget.additional != null)
                        Text(
                          widget.additional!,
                          style: theme.textTheme.displaySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: widget.icon),
          ],
        ),
      ),
    );
  }
}
