import java.io.File

pluginManagement {

    val localProperties = java.util.Properties()

    val localPropertiesFile = file("local.properties")

    require(localPropertiesFile.exists()) {
        "local.properties missing"
    }

    localPropertiesFile.inputStream().use {
        localProperties.load(it)
    }

    val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    require(flutterSdkPath != null) {
        "flutter.sdk not set in local.properties"
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}

include(":app")
