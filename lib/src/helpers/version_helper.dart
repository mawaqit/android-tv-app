class VersionHelper {
  static String extractVersion(String fileName) {
    RegExp versionRegex = RegExp(r'v(\d+\.\d+\.\d+)');
    Match? match = versionRegex.firstMatch(fileName);
    return match?.group(1) ?? '';
  }

  static int compareVersions(String version1, String version2) {
    List<int> v1Parts = version1.split('.').map(int.parse).toList();
    List<int> v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }

    return 0;
  }

  static bool isNewer(String version1, String version2) {
    return compareVersions(version1, version2) > 0;
  }

  static bool isOlder(String version1, String version2) {
    return compareVersions(version1, version2) < 0;
  }

  static bool areEqual(String version1, String version2) {
    return compareVersions(version1, version2) == 0;
  }
}
