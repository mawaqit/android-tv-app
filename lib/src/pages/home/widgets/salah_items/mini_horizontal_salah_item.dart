import 'package:flutter/material.dart';

class MiniHorizontalSalahItem extends StatelessWidget {
  const MiniHorizontalSalahItem({
    Key? key,
    required this.title,
    required this.time,
  }) : super(key: key);

  /// used to show salah name
  final String title;

  /// used to show salah time
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
