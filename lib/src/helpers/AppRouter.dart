import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

/// should be used instead of [Navigator.of(context)] to give support for firebase analytics
class AppRouter {
  static final navigationKey = GlobalKey<NavigatorState>();

  AppRouter._();

  static Future<T?> popAndPush<T, TO>(
    Widget screen, {
    String? name,
    TO? result,
  }) async {
    navigationKey.currentState!.pop<TO>(result);
    return navigationKey.currentState!.push<T>(
      _buildRoute<T>(screen, name: name),
    );
  }

  static Future<T?> push<T>(Widget screen, {String? name}) {
    return navigationKey.currentState!.push<T>(
      _buildRoute<T>(screen, name: name),
    );
  }

  static Future<T?> pushReplacement<T, To>(
    Widget screen, {
    String? name,
    To? result,
  }) =>
      navigationKey.currentState!.pushReplacement<T, To>(
        _buildRoute<T>(screen, name: name),
        result: result,
      );

  static void pop<T>([T? results]) => navigationKey.currentState!.pop(results);

  static void popAll<T>([T? results]) => navigationKey.currentState!.popUntil((route) => route.isFirst);

  static Route<T> _buildRoute<T>(Widget screen, {String? name}) => PageTransition<T>(
        child: screen,
        type: _pageTransitionAnimation,
        settings: RouteSettings(name: name ?? screen.runtimeType.toString()),
      );

  static get _pageTransitionAnimation {
    return Directionality.of(navigationKey.currentContext!) == TextDirection.ltr
        ? PageTransitionType.leftToRight
        : PageTransitionType.rightToLeft;
  }
}
