plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
     
}

android {
    namespace = "com.example.hathari_app"
    // هنا قمت بتعديل السطرين ليكون إصدار الـ NDK ثابت
    ndkVersion = "27.0.12077973" 
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // تفعيل دعم المكتبات الحديثة
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.hathari_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

// أضيفي هذا الجزء في النهاية تماماً لإصلاح خطأ التنبيهات
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
apply (plugin="com.google.gms.google-services")
