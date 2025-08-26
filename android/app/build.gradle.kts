import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// دالة لقراءة ملف الخصائص
fun getProps(path: String): Properties {
    val props = Properties()
    props.load(FileInputStream(file(path)))
    return props
}

// قراءة ملف key.properties
val keyProps by lazy { getProps("../key.properties") }

android {
    namespace = "com.imarket.jo.imarket"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.imarket.jo.imarket"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // إضافة إعدادات التوقيع
    signingConfigs {
        create("release") {
            keyAlias = keyProps["keyAlias"] as String
            keyPassword = keyProps["keyPassword"] as String
            storeFile = file(keyProps["storeFile"] as String)
            storePassword = keyProps["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // تفعيل تصغير حجم الكود للنسخة النهائية
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // إخبار النسخة النهائية باستخدام إعدادات التوقيع التي أنشأناها
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}