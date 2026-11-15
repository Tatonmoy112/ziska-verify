plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ziskapharma.trackandtrace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ziskapharma.trackandtrace"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Three flavors (final.md Section 2.3). Each has its own application ID,
    // so the mock, staging, and live builds install side by side. Android
    // forbids flavor names starting with "test", so the build for the
    // backend's test server is named "staging".
    flavorDimensions += "environment"
    productFlavors {
        create("mock") {
            dimension = "environment"
            applicationIdSuffix = ".mock"
            resValue("string", "app_name", "Track & Trace Mock")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Track & Trace Staging")
        }
        create("live") {
            dimension = "environment"
            resValue("string", "app_name", "Track & Trace")
        }
    }

    buildTypes {
        release {
            // Release signing is configured in CI (final.md Section 2.3).
            // Debug keys keep `flutter run --release` working locally.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
