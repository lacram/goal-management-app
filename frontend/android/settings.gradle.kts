pluginManagement {
    val localProperties = java.util.Properties()
    val localPropertiesFile = File(rootProject.projectDir, "local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
            localProperties.load(reader)
        }
    }
    val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
    
    // 슬래시로 변환
    val normalizedPath = flutterSdkPath.replace("\\", "/")
    
    includeBuild("$normalizedPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
