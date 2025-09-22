plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.connectidwallet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.connectidwallet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders += mapOf(
            "appAuthRedirectScheme" to "dummy"
        )
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }

        // (opsional) kalau mau spesifik hanya untuk debug:
        // debug {
        //     manifestPlaceholders["appAuthRedirectScheme"] = "dummy"
        // }
    }
}

flutter {
    source = "../.."
}
