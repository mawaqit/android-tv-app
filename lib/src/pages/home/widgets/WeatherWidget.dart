import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sunny),
        SizedBox(width: 5),
        Text(
          "45 ",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.yellow[700]),
        ),
        Text(
          "°C",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow[700], height: .5),
        ),
      ],
    );
  }
}
