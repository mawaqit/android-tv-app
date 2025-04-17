plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mawaqit.androidtv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mawaqit.androidtv"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Add Firebase Crashlytics configuration
        manifestPlaceholders["crashlyticsCollectionEnabled"] = false
    }

    signingConfigs {
      release {
        if (System.getenv()["CI"]) { // CI=true is exported by Codemagic
          storeFile file(System.getenv()["CM_KEYSTORE_PATH"])
          storePassword System.getenv()["CM_KEYSTORE_PASSWORD"]
          keyAlias System.getenv()["CM_KEY_ALIAS"]
          keyPassword System.getenv()["CM_KEY_PASSWORD"]
        } else {
          keyAlias keystoreProperties['keyAlias']
          keyPassword keystoreProperties['keyPassword']
          storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
          storePassword keystoreProperties['storePassword']
        }
      }
      isMinifyEnabled = false
      isShrinkResources = false
    }

    buildTypes {
      release {
        signingConfig signingConfigs.release
      }
    }
}

flutter {
    source = "../.."
}
