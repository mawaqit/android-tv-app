import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Screen'),
        actions: [
          IconButton(
            onPressed: () {
              log('Search button pressed');
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushNamed('/quran/reciter-selection');
              },
              child: Text('Go to Reciter Selection'),
            ),
          ],
        ),
      ),
    );
  }
}
