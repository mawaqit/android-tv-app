import 'package:flutter/foundation.dart';

extension PerformanceHelper<T> on Future<T> {
  Future<T> logPerformance(String name) async {
    /// disable performance logs in release mode
    if (!kDebugMode) return this;

    print('[$name]: start');
    final stopwatch = Stopwatch()..start();
    final result = await this;
    stopwatch.stop();
    print('[$name]: ${stopwatch.elapsedMilliseconds}ms');
    return result;
  }
}
