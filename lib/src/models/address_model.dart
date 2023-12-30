import 'dart:io';

enum ConnectivityStatus {
  disconnected,
  connected,
}

class AddressCheckOptions {
  final InternetAddress address;

  AddressCheckOptions(this.address);

  @override
  String toString() => "AddressCheckOptions($address)";
}

class AddressCheckResult {
  final AddressCheckOptions options;
  final bool isSuccess;

  AddressCheckResult(
    this.options,
    this.isSuccess,
  );

  @override
  String toString() => "AddressCheckResult($options, $isSuccess)";
}
