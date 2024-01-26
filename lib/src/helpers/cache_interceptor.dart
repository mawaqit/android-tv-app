import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_info.dart';


/// [CacheInterceptorHelper] class is used to create a cache interceptor for Dio requests.
/// It helps in managing the caching policy for network requests.
class CacheInterceptorHelper  {
  const CacheInterceptorHelper();

  /// [createInterceptor] Creates a DioCacheInterceptor based on the current state of the device.
  /// The caching policy is determined by the device storage.
  (DioCacheInterceptor ,bool) createInterceptor(AsyncValue<DeviceInfo> deviceManager, String path) {
    return deviceManager.when(
      data: (deviceInfo) {
        return (_createCacheInterceptor(CachePolicy.request, path), true);
      },
      loading:() {
        return (_createCacheInterceptor(CachePolicy.request, path), true);
      },
      error: (err, stack) {
        return (_createCacheInterceptor(CachePolicy.noCache, path), false);
      },
    );
  }

  /// [_createCacheInterceptor] Private helper method to create a DioCacheInterceptor with specific cache policies.
  DioCacheInterceptor _createCacheInterceptor(CachePolicy policy, String path) {
    return DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(
          path == '' ? null : path,
          hiveBoxName: 'mawaqit',
        ),
        policy: policy,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        hitCacheOnErrorExcept: [401, 403],
      ),
    );
  }
}
