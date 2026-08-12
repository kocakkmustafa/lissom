plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yulalab.lissom"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.yulalab.lissom"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ⛔ RELEASE İMZASI — SESSİZ DÜŞÜŞ YASAK (L-286).
    //
    // Buradaki Flutter varsayılanı release'i **debug anahtarlarıyla**
    // imzalıyordu ve `TODO` beş gün boyunca kimseye görünmedi: derleme
    // BAŞARILI oluyor, AAB üretiliyor, ve kusur ancak **Play reddedince**
    // ortaya çıkıyordu. Ailenin "sessiz-hiçlik" kuralının imza katmanı:
    // ***bugün sessizce üretilip Play'de reddedilecek bir şeyi, yerelde
    // adıyla durduruyoruz.***
    //
    // Gerçek imza `android/key.properties` ile gelir; o dosya git'te
    // DEĞİLDİR ve keystore workspace'te DURMAZ (sırlar `~/.secrets/yula/`).
    // Debug anahtarına düşmek artık bir VARSAYILAN değil, açıkça istenen
    // bir KARAR: `-PallowDebugSigning=true`.
    val keyPropsFile = rootProject.file("key.properties")
    val keyProps = java.util.Properties().apply {
        if (keyPropsFile.exists()) keyPropsFile.inputStream().use { load(it) }
    }
    val hasRealSigning = keyProps.getProperty("storeFile") != null

    if (hasRealSigning) {
        signingConfigs {
            create("release") {
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            val allowDebugSigning = project.hasProperty("allowDebugSigning")
            // Yalnız GERÇEKTEN bir release görevi istendiğinde patla —
            // aksi hâlde debug derlemeleri de kırılırdı (kapı, ürünün
            // kendisini engellememeli).
            val wantsRelease = gradle.startParameter.taskNames.any {
                it.contains("Release") || it.contains("bundle")
            }

            when {
                hasRealSigning ->
                    signingConfig = signingConfigs.getByName("release")

                allowDebugSigning -> {
                    signingConfig = signingConfigs.getByName("debug")
                    logger.warn(
                        "⚠️  Lissom: release DEBUG anahtarlarıyla imzalanıyor " +
                        "(-PallowDebugSigning). Bu çıktı Play'e YÜKLENEMEZ."
                    )
                }

                wantsRelease -> throw GradleException(
                    "\n⛔ Lissom: release imzası YOK — bu derleme durduruldu.\n" +
                    "   `android/key.properties` bulunamadı, ve debug " +
                    "anahtarlarıyla imzalanmış bir AAB'yi Play REDDEDER.\n" +
                    "   Bu, sessizce üretilip mağazada reddedilecek bir " +
                    "çıktıyı YERELDE durduran kapıdır (L-286).\n\n" +
                    "   Çözüm: kurucudan `Lissom Android release keystore` " +
                    "iste; `key.properties` şunları taşır:\n" +
                    "     storeFile · storePassword · keyAlias · keyPassword\n" +
                    "   Keystore workspace'te DURMAZ (`~/.secrets/yula/`).\n\n" +
                    "   Bilerek imzasız bir yerel release istiyorsan: " +
                    "-PallowDebugSigning=true\n"
                )

                // Release istenmiyor (debug/test yolu) — imza sorusu doğmaz.
                else -> signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
