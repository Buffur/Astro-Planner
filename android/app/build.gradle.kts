import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// TASK 16.2: release signing with the owner's upload key, read from
// android/key.properties (gitignored; never committed — see
// docs/RELEASE.md). Google Play App Signing re-signs the app with the app
// signing key Google keeps; this key only proves an upload is the owner's.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasUploadKey = keystorePropertiesFile.exists()

android {
    namespace = "io.github.chacha12.astroplanner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Owner decision OD-07 (TASK 16.1); permanent once published.
        applicationId = "io.github.chacha12.astroplanner"
        // Flutter's defaults (Flutter 3.47.4: min 24, target 36). Play requires
        // target 36 for new apps and updates from 31 Aug 2026 (TASK 16.2).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // With android/key.properties: the upload key. Without it (a
            // developer machine): the debug key, so `flutter run --release`
            // still works — Google Play rejects a debug-signed bundle, so
            // such a build cannot be uploaded by mistake.
            signingConfig = if (hasUploadKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "android/key.properties not found: the release build is " +
                        "signed with the DEBUG key and cannot be uploaded. " +
                        "See docs/RELEASE.md."
                )
                signingConfigs.getByName("debug")
            }
            // R8 (code shrinking and resource shrinking) is on for release,
            // as the Flutter Gradle plugin sets it (TASK 16.2 decision).
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
