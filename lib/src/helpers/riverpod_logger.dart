import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiverpodLogger extends ProviderObserver {
  @override
  void didAddProvider(
      ProviderBase<Object?> provider,
      Object? value,
      ProviderContainer container,
      ) {
    log('Provider $provider was initialized with $value', name: 'RiverpodLogger');
  }

  @override
  void didDisposeProvider(
      ProviderBase<Object?> provider,
      ProviderContainer container,
      ) {
    log('Provider $provider was disposed', name: 'RiverpodLogger');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    log('''
       {
          "provider": "${provider.name ?? provider.runtimeType}",
          "newValue": "$newValue",
          "previousValue": "$previousValue",
       }
    ''');
  }
}
