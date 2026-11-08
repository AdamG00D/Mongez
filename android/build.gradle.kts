allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // home_widget declares "glance-appwidget:1.+", which now resolves to an
    // alpha that needs compileSdk 37 / AGP 9.1. Pin the latest stable release
    // so builds stay reproducible.
    configurations.all {
        resolutionStrategy.force("androidx.glance:glance-appwidget:1.1.1")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some plugins (e.g. home_widget) still compile for JVM 1.8, which current
// Kotlin refuses to combine with JVM 11+ libraries. Align every plugin module
// on Java/Kotlin 17 like the app module.
subprojects {
    afterEvaluate {
        if (name != "app") {
            extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
                ?.compileOptions
                ?.apply {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
                .configureEach {
                    compilerOptions.jvmTarget.set(
                        org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17,
                    )
                }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
