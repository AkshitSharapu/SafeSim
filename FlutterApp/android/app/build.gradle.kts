plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.safesim.app"
    compileSdk = maxOf(flutter.compileSdkVersion, 36)
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    defaultConfig {
        applicationId = "com.safesim.app"
        minSdk = 26
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk { abiFilters += "arm64-v8a" }
    }
    buildTypes {
        release {
            // Development install only. Configure a private release key before distribution.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    packaging { jniLibs { useLegacyPackaging = true } }
    androidResources { noCompress += listOf("unity3d", "ress", "resource", "obb", "bundle") }
    if (rootProject.findProject(":unityLibrary") != null) {
        sourceSets.getByName("main").manifest.srcFile("src/unity/AndroidManifest.xml")
    }
}
flutter { source = "../.." }
dependencies {
    if (rootProject.findProject(":unityLibrary") != null) implementation(project(":unityLibrary"))
}
