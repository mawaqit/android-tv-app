import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data_source/device_info_data_source.dart';
import '../../data/repository/device_info_impl.dart';
import '../model/device_info_model.dart';
import '../repository/device_repository.dart';

class OnBoardingUseCase {
  final DeviceInfoRepository deviceInfoRepository;

  /// shared preference instance
  OnBoardingUseCase({
    required this.deviceInfoRepository,
  });

  Future<DeviceInfoModel> getDeviceInfo() async {
    final deviceInfoModel = await deviceInfoRepository.getAllDeviceInfo();
    return deviceInfoModel;
  }

  Future<String> getDeviceLanguage() async {
    final deviceLanguage = await deviceInfoRepository.getLanguageWithoutCache();
    return deviceLanguage;
  }

  Future<void> setOnboardingAppLanguage(String language) async {
    await deviceInfoRepository.setLanguage(language, '');
  }
}

final deviceInfoUseCaseProvider = FutureProvider<OnBoardingUseCase>(
  (ref) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    final deviceInfoRepository = await ref.read(deviceInfoImplProvider(
      DeviceInfoImplProviderArgument(
        deviceInfoDataSource: DeviceInfoDataSource(),
        sharedPreferences: sharedPreference,
      ),
    ).future);
    return OnBoardingUseCase(
      deviceInfoRepository: deviceInfoRepository,
    );
  },
);
