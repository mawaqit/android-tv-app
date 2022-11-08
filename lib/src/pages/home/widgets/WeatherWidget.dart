import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sunny_snowing,
          size: 30,
          color: Colors.white,
        ),
        SizedBox(width: 5),
        Text(
          "45 ",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                // color: Colors.yellow[700],
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
        Text(
          "°C",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            height: .5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
