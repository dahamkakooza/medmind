plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.medmind"
<<<<<<< HEAD
    compileSdk = 36
=======
    compileSdk = 34 // Explicitly set to 34 (was using Flutter default)
    ndkVersion = "27.0.12077973"
>>>>>>> 591dbeb (profile tab fix)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.medmind"
<<<<<<< HEAD
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true  // Add this
=======
        minSdk = flutter.minSdkVersion // Explicitly set minSdk (was using Flutter default)
        targetSdk = 34 // Explicitly set to 34 (was using Flutter default)
        versionCode = 1
        versionName = "1.0.0"
>>>>>>> 591dbeb (profile tab fix)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}
