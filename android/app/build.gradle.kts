import java.util.Properties
import java.io.FileInputStream

  plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
  }

// Load key.properties for local development
val keystorePropsFile = rootProject.file("key.properties")
val keystoreProps = Properties().apply {
  if (keystorePropsFile.exists()) {
    load(FileInputStream(keystorePropsFile))
  }
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

    val appVersionCode = (System.getenv()["NEW_BUILD_NUMBER"] ?: flutter.versionCode).toString().toInt()

    defaultConfig {
        applicationId = "com.mawaqit.androidtv"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = appVersionCode
        versionName = flutter.versionName
        manifestPlaceholders["crashlyticsCollectionEnabled"] = false
    }

    signingConfigs {
        create("release") {
          if (System.getenv()["CI"] == "true") {
            storeFile = file(System.getenv()["CM_KEYSTORE_PATH"])
            storePassword = System.getenv()["CM_KEYSTORE_PASSWORD"]
            keyAlias = System.getenv()["CM_KEY_ALIAS"]
            keyPassword = System.getenv()["CM_KEY_PASSWORD"]
          } else {
            storeFile = rootProject.file(keystoreProps["storeFile"] as String)
            storePassword = keystoreProps["storePassword"] as String
            keyAlias = keystoreProps["keyAlias"] as String
            keyPassword = keystoreProps["keyPassword"] as String
          }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}



flutter {
    source = "../.."
}
