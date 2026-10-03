@file:Suppress("DEPRECATION")

// ⚠️ `java.util.Properties`i NİTELİKLİ adla yazmak Gradle Kotlin DSL'inde
// DERLENMEZ: `java` burada `JavaPluginExtension`a çözümleniyor ve paket adını
// GÖLGELİYOR (`Unresolved reference: util`). İçe aktarma ZORUNLU — ve bunu
// metin kapısı göremezdi, ancak GERÇEK derleme gösterdi (L-286 EK).
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yulalab.lissom"
    compileSdk = 37
    buildToolsVersion = "37.0.0"
    ndkVersion = "30.0.16248370"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.yulalab.lissom"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 37
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
    val keyProps = Properties()
    if (keyPropsFile.exists()) {
        keyPropsFile.inputStream().use { keyProps.load(it) }
    }
    val hasRealSigning = keyProps.getProperty("storeFile") != null
    val allowDebugSigning = providers.gradleProperty("allowDebugSigning").orNull == "true"

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
            when {
                hasRealSigning ->
                    signingConfig = signingConfigs.getByName("release")

                allowDebugSigning -> {
                    signingConfig = signingConfigs.getByName("debug")
                    logger.warn(
                        "⚠️  Lissom: release DEBUG anahtarlarıyla imzalanıyor " +
                        "(-PallowDebugSigning=true). Bu çıktı Play'e YÜKLENEMEZ."
                    )
                }

                // No signing fallback is applied while debug-only tasks are
                // configured. Any actual release task is rejected below.
                else -> signingConfig = null
            }
        }
    }

    if (!hasRealSigning && !allowDebugSigning) {
        // Requested names can be generic assemble or a wrapper task. Inspect
        // their resolved dependency graph, before any tasks execute. The app
        // project scope keeps unrelated plugin tasks out of this decision.
        gradle.taskGraph.whenReady {
            val graph = this
            if (graph.allTasks.any { task ->
                task.project == project && task.name.contains("Release", ignoreCase = true)
            }) {
                throw GradleException(
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
