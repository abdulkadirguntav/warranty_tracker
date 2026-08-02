plugins {
    id("com.android.application")
    // Built-in Kotlin is provided by the Flutter Gradle plugin, so the
    // standalone Kotlin Gradle plugin (org.jetbrains.kotlin.android) no
    // longer needs to be explicitly applied here. See:
    // https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Load the release signing configuration from key.properties when present.
// See key.properties.example for setup instructions. The file and keystore
// are gitignored so the signing secrets are never committed.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("app/key.properties")
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.garantitakip.warranty_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.garantitakip.warranty_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasKeystoreProperties) {
                signingConfigs.getByName("release")
            } else {
                // Fall back to debug signing only so local `flutter run --release`
                // keeps working. Create key.properties (see key.properties.example)
                // to produce a Play Store ready, properly signed release build.
                signingConfigs.getByName("debug")
            }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
