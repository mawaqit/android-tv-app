import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class RiverpodSentryProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    Sentry.captureException(error, stackTrace: stackTrace);
    super.providerDidFail(provider, error, stackTrace, container);
  }
}
